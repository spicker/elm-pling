port module Pling exposing (..)

import Html exposing (..)
import Html.Events exposing (..)
import Html.Attributes exposing (..)
import Html.App exposing (..)
import Matrix exposing (..)
import Time exposing (Time, minute, every, second)
import List
import Json.Encode as Json exposing (..)

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
    , bpm : Time }


type alias Tone = Int


init : (Model, Cmd Msg)
init = 
    let 
        model = 
            { matrix = repeat (8,8) False 
            , bpm = 80 }
    in  
        ( model
        , Cmd.none )


--UPDATE
type Msg = 
    Reset
    | Click Position
    | Update Time
    

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    case msg of
        Click position -> 
            ( { model | matrix = toggle position model.matrix }
            , Cmd.none )
            
        Update time ->
            ( model
            , play model.matrix (model.bpm/(60*8)) |> playNotes)
            
        Reset -> 
            init


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
            (\xy -> button [ buttonStyle (Maybe.withDefault False (get xy model.matrix)), onClick (Click xy) ] [text "b"])
            (List.map ((,) x) [0..y])
            |> span []

        
        buttonGrid : (Int,Int) -> Html Msg
        buttonGrid (x,y) = 
            List.map (\a -> div [] [buttonList a x]) [0..y]
            |> ul []

    in
        buttonGrid (7,7)


buttonStyle : Bool -> Html.Attribute Msg
buttonStyle b = 
    case b of 
        True -> 
            style 
                [ ("background-color", "blue") 
                , ("font-size", "24px")]
        False -> 
            style 
                [ ("background-color", "red") 
                , ("font-size", "24px")]


--SUBSCRIPTIONS
subscriptions : Model -> Sub Msg
subscriptions model = 
    every ((minute/model.bpm)*2) Update 