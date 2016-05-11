import Html exposing (..)
import Html.Events exposing (..)
import Html.Attributes exposing (..)
import Html.App exposing (..)
import Matrix exposing (..)
import Time exposing (Time, minute)


main = 
    Html.App.program {init = init, update = update, view = view, subscriptions = \_ -> Sub.none }


--MODEL
type alias Model =
    { matrix : Matrix Bool
    , tones : List Tone
    , bpm : Time }


type alias Tone = 
    String


init : (Model, Cmd Msg)
init = 
    (   { matrix = repeat (8,8) False
        , tones = []
        , bpm = minute * 100 
        }
    , Cmd.none )


--UPDATE
type Msg = 
    Reset
    | Click Position
    
    
update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    case msg of
        Click position -> 
            ( { model | matrix = toggle position model.matrix }
            , Cmd.none)
            
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
view  { matrix, tones } =
    let 
        buttonList : Int -> Int -> Html Msg
        buttonList x y = 
            List.map
            (\xy -> button [ buttonStyle (Maybe.withDefault False (get xy matrix)), onClick (Click xy) ] [text "b"])
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
            style [ ("color", "blue") ]
        False -> 
            style [ ("color", "red") ]

