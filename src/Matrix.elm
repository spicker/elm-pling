module Matrix exposing (..)

import Array exposing(Array)


type alias Position = (Int, Int)

type alias Matrix a = Array (Array a)


empty : Matrix a 
empty = Array.empty

repeat : (Int, Int) -> a -> Matrix a 
repeat (x,y) a = Array.repeat x (Array.repeat y a) 

length : Matrix a -> (Int,Int)
length mat = 
    let
        a = Array.length mat
        b = Array.length (Maybe.withDefault Array.empty (Array.get 0 mat))
    in 
        (a,b)

isEmpty : Matrix a -> Bool
isEmpty = Array.isEmpty

append : Matrix a -> Matrix a -> Matrix a 
append = Array.append

get : Position -> Matrix a -> Maybe a 
get (a,b) mat =  Array.get a mat `Maybe.andThen` Array.get b

getY : Int -> Matrix a -> Maybe (Array a)
getY y = 
    Array.foldl (\x a -> Maybe.map2 Array.push (Array.get y x) a) (Just Array.empty)
    
set : Position -> a -> Matrix a -> Matrix a 
set (x,y) a mat = 
    case Array.get x mat of
        Nothing -> mat
        Just arra -> Array.set x (Array.set y a arra) mat

fold : (a -> b -> b) -> b -> Matrix a -> b
fold f b mat = Array.foldl (\a bs -> Array.foldl f bs a) b mat

map : (a -> b) -> Matrix a -> Matrix b
map f = Array.map (\a -> Array.map f a)

filter : (a -> Bool) -> Matrix a -> Matrix a 
filter f = Array.filter (not << Array.isEmpty) << Array.map (\bss -> Array.filter f bss)

toList : Matrix a -> List a
toList matrix =
    fold (\a bs -> a::bs) [] matrix
    
toPositionList : Matrix a -> List (Position,a)
toPositionList matrix =
    Array.map Array.toIndexedList matrix
    |> Array.toIndexedList
    |> List.map (\(i,l) -> List.map (\(y,a) -> ((i,y),a)) l)
    |> List.concat

t1 : Matrix Int
t1 = repeat (5,2) 1

t2 = repeat (3,2) True

t3 = Array.push (Array.fromList [0..4]) <| Array.push (Array.fromList [1..5]) <| Array.push (Array.fromList [2..6]) Array.empty

testfold : Int
testfold = (fold (+) 0 t1)
       