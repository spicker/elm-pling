module Pling where

import Html exposing (..)
import Html.Events exposing (..)
import Html.Attributes exposing (..)
import Matrix exposing (..)


--MODEL
type alias Model = Matrix Bool

init : Model
init = repeat (8,8) False

--UPDATE
type Action = 
    Reset
    | Click Position
    
update : Action -> Model -> Model
update action model =
    case action of
        Click position -> toggle position model
        Reset -> init

toggle : Position -> Model -> Model
toggle pos model =
    case get pos model of 
        Just True -> set pos False model
        Just False -> set pos True model
        Nothing -> set pos False model

--VIEW
view : Signal.Address Action -> Model -> Html
view address model =
    let 
        buttonList : Int -> Int -> Html 
        buttonList x y = span [] (List.map (\xy -> button [ buttonStyle (Maybe.withDefault False (get xy model)), onClick address (Click xy) ] [text "b"]) (positionList x y))
    in
        div []
            [ buttonList 0 7
            ,
        div []
            [ buttonList 1 7
            ,
        div []
            [ buttonList 2 7
            ,
        div []
            [ buttonList 3 7
            ,
        div []
            [ buttonList 4 7
            ,
        div []
            [ buttonList 5 7
            ,
        div []
            [ buttonList 6 7
            ,
        div []
            [ buttonList 7 7
            ]]]]]]]]
    
        
buttonStyle : Bool -> Html.Attribute
buttonStyle b = 
    case b of 
        True -> style [ ("color", "blue") ]
        False -> style [ ("color", "red") ]

positionList : Int -> Int -> List Position
positionList x y = List.map ((,) x) [0..y]