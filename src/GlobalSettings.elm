module GlobalSettings exposing
    ( GlobalSettings
    , TaskCompletionFormat(..)
    , default
    , encoder
    , toggleIgnoreFileNameDate
    , updateColumnName
    , updateTaskCompletionFormat
    , v_0_10_0_decoder
    , v_0_11_0_decoder
    , v_0_5_0_decoder
    , v_0_6_0_decoder
    , v_0_7_0_decoder
    , v_0_9_0_decoder
    )

import ColumnNames exposing (ColumnNames)
import Json.Encode as JE
import TsJson.Decode as TsDecode
import TsJson.Encode as TsEncode



-- TYPES


type TaskCompletionFormat
    = NoCompletion
    | ObsidianCardBoard
    | ObsidianDataview
    | ObsidianTasks


type alias GlobalSettings =
    { taskCompletionFormat : TaskCompletionFormat
    , columnNames : ColumnNames
    , ignoreFileNameDates : Bool
    }


default : GlobalSettings
default =
    { taskCompletionFormat = ObsidianCardBoard
    , columnNames = ColumnNames.default
    , ignoreFileNameDates = False
    }



-- UTILITIES


toggleIgnoreFileNameDate : GlobalSettings -> GlobalSettings
toggleIgnoreFileNameDate gs =
    { gs | ignoreFileNameDates = not gs.ignoreFileNameDates }


updateColumnName : String -> String -> GlobalSettings -> GlobalSettings
updateColumnName column name gs =
    { gs | columnNames = ColumnNames.updateColumnName column name gs.columnNames }


updateTaskCompletionFormat : String -> GlobalSettings -> GlobalSettings
updateTaskCompletionFormat taskCompletionFormat gs =
    { gs | taskCompletionFormat = taskCompletionFormatFromString taskCompletionFormat }



-- SERIALISE


encoder : TsEncode.Encoder GlobalSettings
encoder =
    TsEncode.object
        [ TsEncode.required "taskCompletionFormat" .taskCompletionFormat taskCompletionFormatEncoder
        , TsEncode.required "columnNames" .columnNames ColumnNames.encoder
        , TsEncode.required "ignoreFileNameDates" .ignoreFileNameDates TsEncode.bool
        ]


v_0_11_0_decoder : TsDecode.Decoder GlobalSettings
v_0_11_0_decoder =
    v_0_10_0_decoder


v_0_10_0_decoder : TsDecode.Decoder GlobalSettings
v_0_10_0_decoder =
    TsDecode.succeed GlobalSettings
        |> TsDecode.andMap (TsDecode.field "taskCompletionFormat" taskCompletionFormatDecoder)
        |> TsDecode.andMap (TsDecode.field "columnNames" ColumnNames.decoder)
        |> TsDecode.andMap (TsDecode.field "ignoreFileNameDates" TsDecode.bool)


v_0_9_0_decoder : TsDecode.Decoder GlobalSettings
v_0_9_0_decoder =
    v_0_7_0_decoder


v_0_7_0_decoder : TsDecode.Decoder GlobalSettings
v_0_7_0_decoder =
    TsDecode.succeed GlobalSettings
        |> TsDecode.andMap (TsDecode.field "taskCompletionFormat" taskCompletionFormatDecoder)
        |> TsDecode.andMap (TsDecode.field "columnNames" ColumnNames.decoder)
        |> TsDecode.andMap (TsDecode.succeed False)


v_0_6_0_decoder : TsDecode.Decoder GlobalSettings
v_0_6_0_decoder =
    TsDecode.succeed GlobalSettings
        |> TsDecode.andMap (TsDecode.field "taskCompletionFormat" taskCompletionFormatDecoder)
        |> TsDecode.andMap (TsDecode.succeed ColumnNames.default)
        |> TsDecode.andMap (TsDecode.succeed False)


v_0_5_0_decoder : TsDecode.Decoder GlobalSettings
v_0_5_0_decoder =
    TsDecode.succeed GlobalSettings
        |> TsDecode.andMap (TsDecode.field "taskUpdateFormat" taskCompletionFormatDecoder)
        |> TsDecode.andMap (TsDecode.succeed ColumnNames.default)
        |> TsDecode.andMap (TsDecode.succeed False)



-- PRIVATE


taskCompletionFormatDecoder : TsDecode.Decoder TaskCompletionFormat
taskCompletionFormatDecoder =
    TsDecode.oneOf
        [ TsDecode.literal NoCompletion (JE.string "NoCompletion")
        , TsDecode.literal ObsidianCardBoard (JE.string "ObsidianCardBoard")
        , TsDecode.literal ObsidianDataview (JE.string "ObsidianDataview")
        , TsDecode.literal ObsidianTasks (JE.string "ObsidianTasks")
        ]


taskCompletionFormatEncoder : TsEncode.Encoder TaskCompletionFormat
taskCompletionFormatEncoder =
    TsEncode.union
        (\vNoCompletion vObsidianCardBoard vObsidianDataview vObsidianTasks v ->
            case v of
                NoCompletion ->
                    vNoCompletion

                ObsidianCardBoard ->
                    vObsidianCardBoard

                ObsidianDataview ->
                    vObsidianDataview

                ObsidianTasks ->
                    vObsidianTasks
        )
        |> TsEncode.variantLiteral (JE.string "NoCompletion")
        |> TsEncode.variantLiteral (JE.string "ObsidianCardBoard")
        |> TsEncode.variantLiteral (JE.string "ObsidianDataview")
        |> TsEncode.variantLiteral (JE.string "ObsidianTasks")
        |> TsEncode.buildUnion


taskCompletionFormatFromString : String -> TaskCompletionFormat
taskCompletionFormatFromString source =
    if source == "ObsidianCardBoard" then
        ObsidianCardBoard

    else if source == "ObsidianTasks" then
        ObsidianTasks

    else if source == "ObsidianDataview" then
        ObsidianDataview

    else if source == "NoCompletion" then
        NoCompletion

    else
        ObsidianCardBoard
