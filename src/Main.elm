module Main exposing (..)

import Browser
import Html exposing (Html, div, form, h1, h5, img, input, label, p, small, text)
import Html.Attributes exposing (class, classList, src, type_, value)
import Html.Events exposing (onClick, onInput)
import Round exposing (round)



---- MODEL ----


type alias Model =
    { weight_in_kg : Float
    , overall : String
    , link : String
    , live_link : String
    , addendum : Bool
    , isE1 : Bool
    }


init : ( Model, Cmd Msg )
init =
    ( { weight_in_kg = 0, overall = "overall", link = "", live_link = "", addendum = False, isE1 = False }, Cmd.none )



---- UPDATE ----


type Msg
    = NoOp
    | Tonnage String
    | Overall String
    | Link String
    | LiveLink String
    | Addendum
    | E1


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        Tonnage tonnes ->
            ( { model | weight_in_kg = Result.withDefault 0 (String.toFloat tonnes |> Result.fromMaybe "invalid") }, Cmd.none )

        Overall overall ->
            ( { model | overall = overall }, Cmd.none )

        Link link ->
            ( { model | link = link }, Cmd.none )

        LiveLink live_link ->
            ( { model | live_link = live_link }, Cmd.none )

        Addendum ->
            ( { model | addendum = not model.addendum }, Cmd.none )

        E1 ->
            ( { model | isE1 = not model.isE1 }, Cmd.none )



---- VIEW ----


view : Model -> Html Msg
view model =
    let
        invalidKgsWarning = if isValidTonnage(model.weight_in_kg) then
                            Html.text ""
                        else
                            p [] [ small [ class "text-danger" ] [ text ("Check whether you are entering weight in kgs (not tonnes) " ++  String.fromFloat(model.weight_in_kg)) ] ]

        
    in

    div []
        [ h1 [] [ text "Material Take Off Formatter" ]
        , form [ src "/logo.svg" ]
            [ div [ class "my-5 row" ]
                [ div [ class "col-4" ] [ text "Is E1?" ]
                , div [ class "col-8" ]
                    [ label
                        [ class "form-check-label" ]
                        [ input [ class "form-check-input mr-6", type_ "checkbox", onClick E1 ] []
                        , text " is E1?"
                        ]
                    , p [] [ small [ class "text-muted" ] [ text "(If it's an E1 quote different pricing applies)" ] ]
                    ]
                ]
            , div [ class "my-5 row" ]
                [ div [ class "col-4" ] [ text "Is Addendum?" ]
                , div [ class "col-8" ]
                    [ label
                        [ class "form-check-label" ]
                        [ input [ class "form-check-input mr-6", type_ "checkbox", onClick Addendum ] []
                        , text " Is Addendum?"
                        ]
                    , p [] [ small [ class "text-muted" ] [ text "(If it's an addendum different pricing applies)" ] ]
                    ]
                ]
            , div [ class "my-5 row" ]
                [ div [ class "col-4" ] [ label [ class "form-label" ] [ text "Weight in KGs" ] ]
                , div [ class "col-8" ] [ input [ classList [ ( "form-control", True ), ( "is-valid", isValidTonnage(model.weight_in_kg)), ( "is-invalid", not (isValidTonnage(model.weight_in_kg)))    ], onInput Tonnage ] [] ]                
                , invalidKgsWarning
                ]
            , div [ class "my-5 row" ]
                [ div [ class "col-4" ] [ label [ class "form-label" ] [ text "Overall" ] ]
                , div [ class "col-8" ]
                    [ input [ class "form-control", value model.overall, onInput Overall ] []
                    , p [] [ small [ class "text-muted" ] [ text "Tonnages for what?  Usually it's overall, but for certain items you might say: e.g. 'Building A'" ] ]
                    ]
                ]
            , div [ class "my-5 row" ]
                [ div [ class "col-4" ] [ label [ class "form-label" ] [ text "Google Drive Link" ] ]
                , div [ class "col-8" ]
                    [ input [ class "form-control", onInput Link ] []
                    , p [] [ small [ class "text-muted" ] [ text "Carefully paste the Google Drive link" ] ]
                    ]
                ]
            , div [ class "my-5 row" ]
                [ div [ class "col-4" ] [ label [ class "form-label" ] [ text "Live Link" ] ]
                , div [ class "col-8" ]
                    [ input [ class "form-control", onInput LiveLink ] []
                    , p [] [ small [ class "text-muted" ] [ text "Live Link" ] ]
                    ]
                ]
            ]
        , 
            div [ class "my-5" ]
            [ h5 [class "text-start my-2"] [text "Status Link"],
              input [ classList [ ( "form-control", True ), ( isValid model, True ) ], value (formatResult model) ] []
            , p [] [ small [ class "text-muted" ] [ text "CTRL + A (to select all) and then CTRL + C (to copy) " ] ]
            ]
        , div [ class "my-5" ]
            [ h5 [class "text-start my-2"] [text "Line Item / Invoice Link"],
              input [ classList [ ( "form-control", True ), ( isValid model, True ) ], value (formatLineItemResult model) ] []
            , p [] [ small [ class "text-muted" ] [ text "This is for invoicing purposes: show only the report  without the live link." ] ]
            ]
        ]


e1String : Bool -> String
e1String isAddendum =
    if isAddendum then
        "(E1) "

    else
        ""


addendumString : Bool -> String
addendumString isAddendum =
    if isAddendum then
        "(ADDENDUM) "

    else
        ""

kgs_to_tonnes: Float -> Float
kgs_to_tonnes kgs = 
    kgs / 1000


isValidTonnage: Float -> Bool
isValidTonnage kgs = if kgs > 1000 then
                        True
                    else
                        False

    


formatResult : Model -> String
formatResult model =
    Round.round 2 (kgs_to_tonnes model.weight_in_kg) ++ " tonnes " ++ addendumString model.addendum ++ "(" ++ model.overall ++ ")" ++ ", Link: " ++ model.link ++ ", Live Link: " ++ model.live_link


formatLineItemResult : Model -> String
formatLineItemResult model =
    Round.round 2 (kgs_to_tonnes model.weight_in_kg) ++ " tonnes " ++ e1String(model.isE1) ++ addendumString model.addendum ++ "(" ++ model.overall ++ ")" ++ ", Link: " ++ model.link 


isValid : Model -> String
isValid model =
    if model.weight_in_kg > 0 && not (String.isEmpty model.overall) && not (String.isEmpty model.link) && not (String.isEmpty model.live_link) then
        "is-valid"

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
