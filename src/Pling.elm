module Pling exposing (main)

import Html exposing (..)
import Html.Events exposing (..)
import Html.Attributes exposing (..)
import Html.App exposing (..)
import Matrix exposing (..)
import Time exposing (Time, minute, every)


port playNote : Model -> Cmd msg 


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



init : (Model, Cmd Msg)
init = 
    let 
        model = 
            { matrix = repeat (8,8) False 
            , bpm = 80 }
    in  
        ( model
        , playNote model )



--UPDATE
type Msg = 
    Reset
    | Click Position
    | Update
    


update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    case msg of
        Click position -> 
            ( toggle position model.matrix
            , Cmd.none )
            
        Update ->
            ( model
            , playNote model )
            
        Reset -> 
            init
            

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
            (\xy -> button [ buttonStyle (Maybe.withDefault False (get xy model)), onClick (Click xy) ] [text "b"])
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
    every bpm Update