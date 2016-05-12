port module Pling exposing (..)

import Html exposing (..)
import Html.Events exposing (..)
import Html.Attributes exposing (..)
import Html.App exposing (..)
import Matrix exposing (..)
import Time exposing (Time, minute, every, second)
import List
import Json.Encode as Json exposing (..)
import Platform.Sub exposing (batch)

port playNotes : String -> Cmd msg 


main = 
    Html.App.program 
        { init = init
        , update = update
        , view = view
        , subscriptions = subscriptions }


--MODEL
type alias Model =
    { matrix : Matrix Bool
    , bpm : Time 
    , currentButtons : Int}


type alias Tone = Int


init : (Model, Cmd Msg)
init = 
    let 
        model = 
            { matrix = repeat (8,8) False 
            , bpm = 180 
            , currentButtons = 0}
    in  
        ( model
        , Cmd.none )


--UPDATE
type Msg = 
    Reset
    | Click Position
    | UpdatePlay Time
    | UpdateButton Time
    

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    case msg of
        Click position -> 
            ( { model | matrix = toggle position model.matrix }
            , Cmd.none )
            
        UpdatePlay time ->
            ( model
            , play model.matrix ( 60/model.bpm ) |> playNotes )
            
        UpdateButton time ->
            ( { model | currentButtons = nextButton model.currentButtons }
            , Cmd.none )
            
        Reset -> 
            init


nextButton : Int -> Int
nextButton x = if x < 7 then x + 1 else 0


play : Matrix Bool -> Time -> String
play matrix interval = 
    toPositionList matrix
    |> List.filter (\(pos,b) -> b == True)
    |> List.map fst 
    |> List.map ( \(x,y) -> (x, (toFloat y) * interval))
    |> List.map ( \(a,b) -> Json.object [("tone", int a), ("time", float b)] )
    |> Json.list
    |> Json.encode 0
        
    

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
                        ("btn-play", model.currentButtons == b) ]
                    , onClick (Click (a,b)) ] [])
                (List.map ((,) y) [0..x])
                |> span []

        
        buttonGrid : (Int,Int) -> Html Msg
        buttonGrid (x,y) = 
            List.map (\a -> div [] [buttonList x a]) [0..y]
            |> ul []

    in
        buttonGrid (7,7)


--SUBSCRIPTIONS
subscriptions : Model -> Sub Msg
subscriptions model = 
    Platform.Sub.batch 
        [ every ((minute/model.bpm)*8) UpdatePlay 
        , every (minute/model.bpm) UpdateButton ]
    