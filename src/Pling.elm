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
import String exposing (toFloat)

port playNotes : String -> Cmd msg 
port volume : String -> Cmd msg


main = 
    Html.App.program 
        { init = init
        , update = update
        , view = lazy view
        , subscriptions = subscriptions }


--MODEL
type alias Model =
    { matrix : Matrix Bool
    , bpm : String 
    , currentCol : Int
    , playing : Bool 
    , volume : String }


type alias Tone = Int


init : (Model, Cmd Msg)
init = 
    let 
        model = 
            { matrix = repeat (8,8) False 
            , bpm = "80" 
            , currentCol = 0
            , playing = False 
            , volume = "1" }
    in  
        ( model
        , Cmd.none )


--UPDATE
type Msg = 
    Reset
    | Click Position
    | UpdatePlay Time
    | IsPlaying Bool
    | Volume String
    | Bpm String
    

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
            
        Volume vol ->
            ( { model | volume = vol }
            , volume vol )
            
        Bpm x ->
            ( { model | bpm = x }
            , Cmd.none )
            
        Reset -> 
            init


next : Int -> Int
next x = if x < 7 then x + 1 else 0
    
    
play : Model -> Json.Value
play model = 
    case getY (model.currentCol) model.matrix of 
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
        controls : Html Msg
        controls = 
            div [] 
                [ button 
                    [ class "play controls"
                    , onClick (IsPlaying <| not model.playing) ]
                    [ if model.playing then text "❙❙" else text "▸" ]
                , input 
                    [ class "volume controls"
                    , type' "range"
                    , Html.Attributes.min "0"
                    , Html.Attributes.max "1"
                    , step "0.01"
                    , value model.volume
                    , onInput Volume ] []
                , input 
                    [ class "bpm controls"
                    , type' "text"
                    , value (model.bpm)
                    , onInput Bpm ] []
                , button 
                    [ class "reset controls"
                    , onClick Reset ] 
                    [ text "x" ]
                ]
        
        buttonList : Int -> Int -> Html Msg
        buttonList x y = 
            List.map
                (\(a,b) -> button  
                    [ classList [
                        ("btn", True),
                        ("btn-active", Maybe.withDefault False ( get (a,b) model.matrix )),
                        ("btn-playing", (model.currentCol) == next b) ]
                    , onClick (Click (a,b)) ] [])
                (List.map ((,) y) [0..x])
                |> span []

        
        buttonGrid : Int -> Int -> Html Msg
        buttonGrid x y = 
            controls ::
            List.map (\a -> div [] [buttonList x a]) [0..y]
            |> div [class "grid"]

    in
        buttonGrid 7 7


--SUBSCRIPTIONS
subscriptions : Model -> Sub Msg
subscriptions model = 
    if model.playing then every ((minute/(Result.withDefault 1 <| String.toFloat model.bpm))/2) UpdatePlay else none
        

