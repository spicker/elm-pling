port module Pling exposing (..)

import Html exposing (..)
import Html.Events exposing (..)
import Html.Attributes exposing (..)
import Html.App exposing (program)
import Matrix exposing (..)
import Time exposing (Time, minute, every)
import List
import Json.Encode as Json exposing (Value,object,list,encode,int,float)
import Platform.Sub exposing (batch,none)
import Html.Lazy exposing (lazy)
import Array exposing (toIndexedList)

port playNotes : String -> Cmd msg 


main = 
    Html.App.program 
        { init = init
        , update = update
        , view = lazy view
        , subscriptions = subscriptions }


--MODEL
type alias Model =
    { matrix : Matrix Bool
    , bpm : Time 
    , currentCol : Int
    , playing : Bool }


type alias Tone = Int


init : (Model, Cmd Msg)
init = 
    let 
        model = 
            { matrix = repeat (8,8) False 
            , bpm = 180 
            , currentCol = 0
            , playing = False }
    in  
        ( model
        , Cmd.none )


--UPDATE
type Msg = 
    Reset
    | Click Position
    | UpdatePlay Time
    | IsPlaying Bool
    

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    case msg of
        Click position -> 
            ( { model | matrix = toggle position model.matrix }
            , Cmd.none )
            
        UpdatePlay time ->
            ( { model | currentCol = next model.currentCol }
            , playNotes <| encode 0 <| play model )
             
        IsPlaying bool ->
            ( { model | playing = bool }
            , Cmd.none )
            
        Reset -> 
            init


next : Int -> Int
next x = if x < 7 then x + 1 else 0
    
    
play : Model -> Json.Value
play model = 
    case getY (next model.currentCol) model.matrix of 
        Just array ->
            List.filterMap (\(i,e) -> if e==True then Just i else Nothing) (toIndexedList array)
            |> List.map ( \i -> Json.object [("tone", int i)] )
            |> Json.list
            
        Nothing -> 
            Json.null
    

toggle : Position -> Matrix Bool -> Matrix Bool
toggle pos matrix =
    case get pos matrix of 
        Just True -> 
            set pos False matrix
            
        Just False -> 
            set pos True matrix
            
        Nothing -> 
            set pos False matrix
            

--VIEW
view : Model -> Html Msg
view model =
    let 
        buttonList : Int -> Int -> Html Msg
        buttonList x y = 
            List.map
                (\(a,b) -> button  
                    [ classList [
                        ("btn", True),
                        ("btn-active", Maybe.withDefault False ( get (a,b) model.matrix )),
                        ("btn-playing", model.currentCol == b) ]
                    , onClick (Click (a,b)) ] [])
                (List.map ((,) y) [0..x])
                |> span []

        
        buttonGrid : Int -> Int -> Html Msg
        buttonGrid x y = 
            List.map (\a -> div [] [buttonList x a]) [0..y]
            |> ul []

    in
        div [] [ button [style [("font-size","30px")], onClick (IsPlaying <| not model.playing)] 
            [ if model.playing then text "❙❙" else text "▸"]
            , buttonGrid 7 7
            ]


--SUBSCRIPTIONS
subscriptions : Model -> Sub Msg
subscriptions model = 
    Platform.Sub.batch 
        [ if model.playing then every ((minute/model.bpm)) UpdatePlay else none
        ]
    