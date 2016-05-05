import StartApp.Simple exposing (start)
import Pling exposing (..)

main = start {model = init, update = update , view = view}