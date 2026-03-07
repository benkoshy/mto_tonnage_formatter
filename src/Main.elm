module Main exposing (..)

import Browser
import Html exposing (Html, div, form, h1, img, input, label, p, small, text)
import Html.Attributes exposing (class, src, value, classList)
import Html.Events exposing (onInput)
import Round exposing (round)



---- MODEL ----


type alias Model =
    { tonnage : Float
    , overall : String
    , link : String
    }


init : ( Model, Cmd Msg )
init =
    ( { tonnage = 0, overall = "overall", link = "" }, Cmd.none )



---- UPDATE ----


type Msg
    = NoOp
    | Tonnage String
    | Overall String
    | Link String


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        Tonnage tonnes ->
            ( { model | tonnage = Result.withDefault 0 (String.toFloat tonnes |> Result.fromMaybe "invalid") }, Cmd.none )

        Overall overall ->
            ( { model | overall = overall }, Cmd.none )

        Link link ->
            ( { model | link = link }, Cmd.none )



---- VIEW ----


view : Model -> Html Msg
view model =
    div []
        [ h1 [] [ text "Material Take Off Formatter" ]
        , form [ src "/logo.svg" ]
            [ div [ class "my-5 row" ]
                [ div [ class "col-4" ] [ label [ class "form-label" ] [ text "Tonnage" ] ]
                , div [ class "col-8" ] [ input [ class "form-control", onInput Tonnage ] [] ]
                ]
            , div [ class "my-5 row" ]
                [ div [ class "col-4" ] [ label [ class "form-label" ] [ text "Overall" ] ]
                , div [ class "col-8" ]
                    [ input [ class "form-control", value model.overall, onInput Overall ] []
                    , p [] [ small [ class "text-muted" ] [ text "Tonnages for what?  Usually it's overall, but for certain items you might say: e.g. 'Building A'" ] ]
                    ]
                ]
            , div [ class "my-5 row" ]
                [ div [ class "col-4" ] [ label [ class "form-label" ] [ text "Link" ] ]
                , div [ class "col-8" ]
                    [ input [ class "form-control", onInput Link ] []
                    , p [] [ small [ class "text-muted" ] [ text "Carefully paste the Google Drive link" ] ]
                    ]
                ]
            ]
        , div [ class "my-5 row" ]
            [ input [ classList [("form-control", True), (isValid model, True)] , value (formatResult model) ] [] 
            , p [] [ small [ class "text-muted" ] [ text "CTRL + A (to select all) and then CTRL + C (to copy) " ] ]
            ]
        ]


formatResult : Model -> String
formatResult model =
    "Tonnes: " ++ Round.round 2 model.tonnage ++ " (" ++ model.overall ++ ")" ++ ", Link: " ++ model.link

isValid : Model -> String
isValid model =
    if model.tonnage > 0 && (not (String.isEmpty (model.overall))) && (not (String.isEmpty (model.link)))  then "is-valid"
    else 
        "is-invalid"
    


---- PROGRAM ----


main : Program () Model Msg
main =
    Browser.element
        { view = view
        , init = \_ -> init
        , update = update
        , subscriptions = always Sub.none
        }
