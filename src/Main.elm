module Main exposing (..)

import Browser
import Html exposing (Html, text, div, h1, img, form, label, input, p)
import Html.Attributes exposing (src, class)
import Html.Events exposing (onInput)


---- MODEL ----


type alias Model =
    {tonnage: Float}


init : ( Model, Cmd Msg )
init =
    ( {tonnage = 0 }, Cmd.none )



---- UPDATE ----


type Msg
    = NoOp
    | Tonnage String


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of 
        NoOp
          -> ( model, Cmd.none )
        Tonnage tonnes ->
            (  {model | tonnage = (Result.withDefault 0 ( String.toFloat tonnes |> Result.fromMaybe "invalid")) }, Cmd.none )



---- VIEW ----


view : Model -> Html Msg
view model =
    div []
        [ form [ src "/logo.svg" ] [
          div [ class "mb-3"] [
                label [ class "form-label" ]  [ text "Tonnage"  ],
                input [ class "form-control", onInput Tonnage] [ ]                
          ]
        ],
    div [] [
            p [] [text (String.fromFloat model.tonnage)]
            ]        
        ]



---- PROGRAM ----


main : Program () Model Msg
main =
    Browser.element
        { view = view
        , init = \_ -> init
        , update = update
        , subscriptions = always Sub.none
        }

