module Form.UndatedColumn exposing
    ( Error(..)
    , Form
    , decoder
    , init
    )

import Column.Undated as UndatedColumn exposing (UndatedColumn)
import Form.Decoder as FD
import Form.Input as Input



-- TYPES


type alias Form =
    { name : String
    }


type Error
    = NameRequired



-- CONSTRUCTION


init : UndatedColumn -> Form
init undatedColumn =
    { name = UndatedColumn.name undatedColumn }



-- DECODER


decoder : FD.Decoder Form Error UndatedColumn
decoder =
    FD.map UndatedColumn.init nameDecoder



-- PRIVATE


nameDecoder : FD.Decoder Form Error String
nameDecoder =
    FD.identity
        |> FD.lift String.trim
        |> Input.required NameRequired
        |> FD.lift .name
