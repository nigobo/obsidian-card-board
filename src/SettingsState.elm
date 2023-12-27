module SettingsState exposing
    ( SettingsState(..)
    , addBoardConfirmed
    , addBoardRequested
    , addColumnConfirmed
    , addColumnRequested
    , boardConfigs
    , cancelCurrentState
    , deleteBoardRequested
    , deleteColumnRequested
    , deleteConfirmed
    , editBoardAt
    , editGlobalSettings
    , init
    , mapBoardBeingAdded
    , mapBoardBeingEdited
    , mapColumnBeingAdded
    , mapCurrentColumnsForm
    , mapGlobalSettings
    , moveBoard
    , moveColumn
    , settings
    )

import BoardConfig exposing (BoardConfig)
import Columns exposing (Columns)
import DefaultColumnNames exposing (DefaultColumnNames)
import DragAndDrop.BeaconPosition as BeaconPosition exposing (BeaconPosition)
import Form.Columns as ColumnsForm exposing (ColumnsForm, OptionsForSelect)
import Form.NewBoard as NewBoardForm exposing (NewBoardForm)
import Form.NewColumn exposing (NewColumnForm)
import Form.SafeDecoder as SD
import Form.Settings as SettingsForm exposing (SettingsForm)
import GlobalSettings exposing (GlobalSettings)
import List.Extra as LE
import SafeZipper exposing (SafeZipper)
import Settings exposing (Settings)



-- TYPES


type SettingsState
    = AddingBoard NewBoardForm SettingsForm
    | AddingColumn NewColumnForm SettingsForm
    | ClosingPlugin SettingsForm
    | ClosingSettings SettingsForm
    | DeletingBoard SettingsForm
    | DeletingColumn Int SettingsForm
    | EditingBoard SettingsForm
    | EditingGlobalSettings SettingsForm



-- CREATE


init : Settings -> SettingsState
init settings_ =
    if Settings.hasAnyBordsConfigured settings_ then
        EditingBoard <| SettingsForm.init settings_

    else
        AddingBoard NewBoardForm.default (SettingsForm.init settings_)



-- UTILITIES


boardConfigs : SettingsState -> SafeZipper BoardConfig
boardConfigs settingsState =
    Settings.boardConfigs <| settings settingsState


settings : SettingsState -> Settings
settings settingsState =
    let
        settingsFromForm : SettingsForm -> Settings
        settingsFromForm settingsForm_ =
            SD.run SettingsForm.safeDecoder settingsForm_
                |> Result.withDefault Settings.default
    in
    case settingsState of
        AddingBoard _ settingsForm_ ->
            settingsFromForm settingsForm_

        AddingColumn _ settingsForm_ ->
            settingsFromForm settingsForm_

        ClosingPlugin settingsForm_ ->
            settingsFromForm settingsForm_

        ClosingSettings settingsForm_ ->
            settingsFromForm settingsForm_

        DeletingBoard settingsForm_ ->
            settingsFromForm settingsForm_

        DeletingColumn _ settingsForm_ ->
            settingsFromForm settingsForm_

        EditingBoard settingsForm_ ->
            settingsFromForm settingsForm_

        EditingGlobalSettings settingsForm_ ->
            settingsFromForm settingsForm_



-- TRANSFORM


addBoardConfirmed : DefaultColumnNames -> SettingsState -> SettingsState
addBoardConfirmed defaultColumnNames settingsState =
    case settingsState of
        AddingBoard c settingsForm_ ->
            EditingBoard <| SettingsForm.addBoard defaultColumnNames c settingsForm_

        _ ->
            settingsState


addBoardRequested : SettingsState -> SettingsState
addBoardRequested settingsState =
    case settingsState of
        AddingBoard _ settingsForm_ ->
            settingsState

        AddingColumn _ settingsForm_ ->
            AddingBoard NewBoardForm.default settingsForm_

        ClosingPlugin settingsForm_ ->
            AddingBoard NewBoardForm.default settingsForm_

        ClosingSettings settingsForm_ ->
            AddingBoard NewBoardForm.default settingsForm_

        DeletingBoard settingsForm_ ->
            AddingBoard NewBoardForm.default settingsForm_

        DeletingColumn _ settingsForm_ ->
            AddingBoard NewBoardForm.default settingsForm_

        EditingBoard settingsForm_ ->
            AddingBoard NewBoardForm.default settingsForm_

        EditingGlobalSettings settingsForm_ ->
            AddingBoard NewBoardForm.default settingsForm_


addColumnConfirmed : SettingsState -> SettingsState
addColumnConfirmed settingsState =
    case settingsState of
        AddingColumn c settingsForm_ ->
            SettingsForm.addColumn c settingsForm_
                |> (\f -> EditingBoard f)

        _ ->
            settingsState


addColumnRequested : SettingsState -> SettingsState
addColumnRequested settingsState =
    -- let
    --     columns : ColumnsForm.Form
    --     columns =
    --         settingsState
    --             |> settingsForm
    --             |> SettingsForm.columnsForms
    --             |> SafeZipper.current
    --             |> Maybe.withDefault ColumnsForm.empty
    --     optionsForSelect : List OptionsForSelect
    --     optionsForSelect =
    --         ColumnsForm.optionsForSelect columns (NewColumnForm "" "")
    --     selectedOption : String
    --     selectedOption =
    --         optionsForSelect
    --             |> LE.find .isSelected
    --             |> Maybe.map .value
    --             |> Maybe.withDefault "dated"
    -- in
    case settingsState of
        AddingBoard _ settingsForm_ ->
            -- AddingColumn (NewColumnForm "" selectedOption) settingsForm_
            settingsState

        AddingColumn _ settingsForm_ ->
            settingsState

        ClosingPlugin settingsForm_ ->
            -- AddingColumn (NewColumnForm "" selectedOption) settingsForm_
            settingsState

        ClosingSettings settingsForm_ ->
            -- AddingColumn (NewColumnForm "" selectedOption) settingsForm_
            settingsState

        DeletingBoard settingsForm_ ->
            -- AddingColumn (NewColumnForm "" selectedOption) settingsForm_
            settingsState

        DeletingColumn _ settingsForm_ ->
            -- AddingColumn (NewColumnForm "" selectedOption) settingsForm_
            settingsState

        EditingBoard settingsForm_ ->
            -- AddingColumn (NewColumnForm "" selectedOption) settingsForm_
            settingsState

        EditingGlobalSettings settingsForm_ ->
            -- AddingColumn (NewColumnForm "" selectedOption) settingsForm_
            settingsState


cancelCurrentState : SettingsState -> SettingsState
cancelCurrentState settingsState =
    case settingsState of
        AddingBoard _ settingsForm_ ->
            -- if SettingsForm.hasAnyBordsConfigured settingsForm_ then
            --     init settingsForm_
            -- else
            ClosingPlugin settingsForm_

        AddingColumn _ settingsForm_ ->
            EditingBoard settingsForm_

        ClosingPlugin settingsForm_ ->
            ClosingPlugin settingsForm_

        ClosingSettings settingsForm_ ->
            ClosingSettings settingsForm_

        DeletingBoard settingsForm_ ->
            EditingBoard settingsForm_

        DeletingColumn _ settingsForm_ ->
            EditingBoard settingsForm_

        EditingBoard settingsForm_ ->
            ClosingSettings settingsForm_

        EditingGlobalSettings settingsForm_ ->
            ClosingSettings settingsForm_


deleteBoardRequested : SettingsState -> SettingsState
deleteBoardRequested settingsState =
    case settingsState of
        AddingBoard _ settingsForm_ ->
            DeletingBoard settingsForm_

        AddingColumn _ settingsForm_ ->
            DeletingBoard settingsForm_

        ClosingPlugin settingsForm_ ->
            DeletingBoard settingsForm_

        ClosingSettings settingsForm_ ->
            DeletingBoard settingsForm_

        DeletingBoard settingsForm_ ->
            settingsState

        DeletingColumn _ settingsForm_ ->
            DeletingBoard settingsForm_

        EditingBoard settingsForm_ ->
            DeletingBoard settingsForm_

        EditingGlobalSettings settingsForm_ ->
            DeletingBoard settingsForm_


deleteColumnRequested : Int -> SettingsState -> SettingsState
deleteColumnRequested index settingsState =
    case settingsState of
        AddingBoard _ settingsForm_ ->
            DeletingColumn index settingsForm_

        AddingColumn _ settingsForm_ ->
            DeletingColumn index settingsForm_

        ClosingPlugin settingsForm_ ->
            DeletingColumn index settingsForm_

        ClosingSettings settingsForm_ ->
            DeletingColumn index settingsForm_

        DeletingBoard settingsForm_ ->
            DeletingColumn index settingsForm_

        DeletingColumn _ settingsForm_ ->
            DeletingColumn index settingsForm_

        EditingBoard settingsForm_ ->
            DeletingColumn index settingsForm_

        EditingGlobalSettings settingsForm_ ->
            DeletingColumn index settingsForm_


deleteConfirmed : SettingsState -> SettingsState
deleteConfirmed settingsState =
    case settingsState of
        DeletingBoard settingsForm_ ->
            -- let
            --     newSettings =
            --         Settings.deleteCurrentBoard settings_
            --     newSettingsForm =
            --         SettingsForm.deleteCurrentBoard settingsForm_
            -- in
            -- if Settings.hasAnyBordsConfigured newSettings then
            --     EditingBoard newSettings newSettingsForm
            -- else
            --     AddingBoard NewBoardForm.default newSettings newSettingsForm
            settingsState

        DeletingColumn index settingsForm_ ->
            EditingBoard (SettingsForm.deleteColumn index settingsForm_)

        _ ->
            settingsState


editBoardAt : Int -> SettingsState -> SettingsState
editBoardAt index settingsState =
    case settingsState of
        AddingBoard _ settingsForm_ ->
            EditingBoard
                (SettingsForm.switchToBoard index settingsForm_)

        AddingColumn _ settingsForm_ ->
            EditingBoard
                (SettingsForm.switchToBoard index settingsForm_)

        ClosingPlugin settingsForm_ ->
            EditingBoard
                (SettingsForm.switchToBoard index settingsForm_)

        ClosingSettings settingsForm_ ->
            EditingBoard
                (SettingsForm.switchToBoard index settingsForm_)

        DeletingBoard settingsForm_ ->
            EditingBoard
                (SettingsForm.switchToBoard index settingsForm_)

        DeletingColumn _ settingsForm_ ->
            EditingBoard
                (SettingsForm.switchToBoard index settingsForm_)

        EditingBoard settingsForm_ ->
            EditingBoard
                (SettingsForm.switchToBoard index settingsForm_)

        EditingGlobalSettings settingsForm_ ->
            EditingBoard
                (SettingsForm.switchToBoard index settingsForm_)


editGlobalSettings : SettingsState -> SettingsState
editGlobalSettings settingsState =
    case settingsState of
        AddingBoard _ settingsForm_ ->
            EditingGlobalSettings settingsForm_

        AddingColumn _ settingsForm_ ->
            EditingGlobalSettings settingsForm_

        ClosingPlugin settingsForm_ ->
            EditingGlobalSettings settingsForm_

        ClosingSettings settingsForm_ ->
            EditingGlobalSettings settingsForm_

        DeletingBoard settingsForm_ ->
            EditingGlobalSettings settingsForm_

        DeletingColumn _ settingsForm_ ->
            EditingGlobalSettings settingsForm_

        EditingBoard settingsForm_ ->
            EditingGlobalSettings settingsForm_

        EditingGlobalSettings settingsForm_ ->
            settingsState


moveBoard : String -> BeaconPosition -> SettingsState -> SettingsState
moveBoard draggedId beaconPosition settingsState =
    -- let
    --     boardConfigs_ : List BoardConfig
    --     boardConfigs_ =
    --         boardConfigs settingsState
    --             |> SafeZipper.toList
    --     boardConfigForms_ : List ColumnsForm.Form
    --     boardConfigForms_ =
    --         settingsState
    --             |> settingsForm
    --             |> SettingsForm.columnsForms
    --             |> SafeZipper.toList
    --     paired : List ( BoardConfig, ColumnsForm.Form )
    --     paired =
    --         LE.zip boardConfigs_ boardConfigForms_
    --     boardConfigName : ( BoardConfig, ColumnsForm.Form ) -> String
    --     boardConfigName =
    --         BoardConfig.name << Tuple.first
    --     moved : List ( BoardConfig, ColumnsForm.Form )
    --     moved =
    --         BeaconPosition.performMove draggedId beaconPosition boardConfigName paired
    --     movedIndex : Int
    --     movedIndex =
    --         moved
    --             |> LE.findIndex (\( c, _ ) -> BoardConfig.name c == draggedId)
    --             |> Maybe.withDefault 0
    --     movedBoardConfigs : SafeZipper BoardConfig
    --     movedBoardConfigs =
    --         moved
    --             |> List.map Tuple.first
    --             |> SafeZipper.fromList
    --     movedBoardConfigForms : SafeZipper ColumnsForm.Form
    --     movedBoardConfigForms =
    --         moved
    --             |> List.map Tuple.second
    --             |> SafeZipper.fromList
    --     settingsMapper : Settings -> Settings
    --     settingsMapper settings_ =
    --         { settings_ | boardConfigs = SafeZipper.atIndex movedIndex movedBoardConfigs }
    --     boardConfigsFormMapper : SettingsForm.Form -> SettingsForm.Form
    --     boardConfigsFormMapper settingsForm_ =
    --         { settingsForm_ | columnsForms = SafeZipper.atIndex movedIndex movedBoardConfigForms }
    -- in
    -- settingsState
    --     |> mapSettings settingsMapper
    --     |> mapSettingsForm boardConfigsFormMapper
    settingsState


moveColumn : String -> BeaconPosition -> SettingsState -> SettingsState
moveColumn draggedId beaconPosition settingsState =
    mapSettingsForm (SettingsForm.moveColumn draggedId beaconPosition) settingsState



-- MAPPING


mapBoardBeingAdded : (NewBoardForm -> NewBoardForm) -> SettingsState -> SettingsState
mapBoardBeingAdded fn settingsState =
    case settingsState of
        AddingBoard c settingsForm_ ->
            AddingBoard (fn c) settingsForm_

        _ ->
            settingsState


mapBoardBeingEdited : (BoardConfig -> BoardConfig) -> SettingsState -> SettingsState
mapBoardBeingEdited fn settingsState =
    case settingsState of
        EditingBoard settingsForm_ ->
            -- EditingBoard (Settings.updateCurrentBoard fn settings_) settingsForm_
            settingsState

        _ ->
            settingsState


mapColumnBeingAdded : (NewColumnForm -> NewColumnForm) -> SettingsState -> SettingsState
mapColumnBeingAdded fn settingsState =
    case settingsState of
        AddingColumn c settingsForm_ ->
            AddingColumn (fn c) settingsForm_

        _ ->
            settingsState


mapCurrentColumnsForm : (ColumnsForm -> ColumnsForm) -> SettingsState -> SettingsState
mapCurrentColumnsForm fn settingsState =
    case settingsState of
        EditingBoard settingsForm_ ->
            -- EditingBoard (SettingsForm.updateCurrentColumnsForm fn settingsForm_)
            settingsState

        _ ->
            settingsState


mapGlobalSettings : (GlobalSettings -> GlobalSettings) -> SettingsState -> SettingsState
mapGlobalSettings fn settingsState =
    case settingsState of
        EditingGlobalSettings settingsForm_ ->
            -- EditingGlobalSettings (Settings.mapGlobalSettings fn settings_) settingsForm_
            settingsState

        _ ->
            settingsState



-- PRIVATE


mapSettingsForm : (SettingsForm -> SettingsForm) -> SettingsState -> SettingsState
mapSettingsForm fn settingsState =
    case settingsState of
        AddingBoard config settingsForm_ ->
            AddingBoard config (fn settingsForm_)

        AddingColumn config settingsForm_ ->
            AddingColumn config (fn settingsForm_)

        ClosingPlugin settingsForm_ ->
            ClosingPlugin (fn settingsForm_)

        ClosingSettings settingsForm_ ->
            ClosingSettings (fn settingsForm_)

        DeletingBoard settingsForm_ ->
            DeletingBoard (fn settingsForm_)

        DeletingColumn index settingsForm_ ->
            DeletingColumn index (fn settingsForm_)

        EditingBoard settingsForm_ ->
            EditingBoard (fn settingsForm_)

        EditingGlobalSettings settingsForm_ ->
            EditingGlobalSettings (fn settingsForm_)


settingsForm : SettingsState -> SettingsForm
settingsForm settingsState =
    case settingsState of
        AddingBoard _ settingsForm_ ->
            settingsForm_

        AddingColumn _ settingsForm_ ->
            settingsForm_

        ClosingPlugin settingsForm_ ->
            settingsForm_

        ClosingSettings settingsForm_ ->
            settingsForm_

        DeletingBoard settingsForm_ ->
            settingsForm_

        DeletingColumn _ settingsForm_ ->
            settingsForm_

        EditingBoard settingsForm_ ->
            settingsForm_

        EditingGlobalSettings settingsForm_ ->
            settingsForm_
