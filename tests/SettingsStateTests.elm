module SettingsStateTests exposing (suite)

import BoardConfig exposing (BoardConfig)
import Column
import Column.Completed as CompletedColumn
import Columns
import DefaultColumnNames
import Expect
import Filter
import Form.BoardConfigs as BoardConfigsForm
import Form.Column as ColumnForm exposing (Form)
import Form.Columns as ColumnsForm
import GlobalSettings exposing (GlobalSettings)
import NewBoardConfig exposing (NewBoardConfig)
import NewColumnConfig exposing (NewColumnConfig)
import SafeZipper
import Settings exposing (Settings)
import SettingsState exposing (SettingsState)
import Test exposing (..)


suite : Test
suite =
    concat
        [ addBoardConfirmed
        , addBoardRequested
        , addColumnConfirmed
        , addColumnRequested
        , boardConfigs
        , cancelCurrentState
        , deleteConfirmed
        , deleteBoardRequested
        , deleteColumnRequested
        , editBoardAt
        , editGlobalSettings
        , init
        , mapBoardBeingAdded
        , mapBoardBeingEdited
        , mapColumnBeingAdded
        , mapCurrentColumnsForm
        , mapGlobalSettings
        ]


addBoardConfirmed : Test
addBoardConfirmed =
    describe "addBoardConfirmed"
        [ test "AddingBoard -> EditingBoard focussed on the new board which is on the end" <|
            \() ->
                SettingsState.AddingBoard exampleNewBoardConfig
                    (settingsFromBoardConfigs [ exampleBoardConfig ])
                    BoardConfigsForm.empty
                    |> SettingsState.addBoardConfirmed DefaultColumnNames.default
                    |> Expect.equal
                        (SettingsState.EditingBoard
                            (settingsFromBoardConfigsWithIndex 1
                                [ exampleBoardConfig
                                , BoardConfig.fromNewBoardConfig DefaultColumnNames.default exampleNewBoardConfig
                                ]
                            )
                            BoardConfigsForm.empty
                        )
        , test "AddingBoard -> EditingBoard changes blank name to Unnamed" <|
            \() ->
                SettingsState.AddingBoard noNameNewBoardConfig
                    (settingsFromBoardConfigs [ exampleBoardConfig ])
                    BoardConfigsForm.empty
                    |> SettingsState.addBoardConfirmed DefaultColumnNames.default
                    |> Expect.equal
                        (SettingsState.EditingBoard
                            (settingsFromBoardConfigsWithIndex 1
                                [ exampleBoardConfig
                                , BoardConfig.fromNewBoardConfig DefaultColumnNames.default unnamedNameNewBoardConfig
                                ]
                            )
                            BoardConfigsForm.empty
                        )
        , test "does nothing if AddingColumn" <|
            \() ->
                SettingsState.AddingColumn (NewColumnConfig "" "") Settings.default BoardConfigsForm.empty
                    |> SettingsState.addBoardConfirmed DefaultColumnNames.default
                    |> Expect.equal (SettingsState.AddingColumn (NewColumnConfig "" "") Settings.default BoardConfigsForm.empty)
        , test "does nothing if ClosingPlugin" <|
            \() ->
                SettingsState.ClosingPlugin Settings.default BoardConfigsForm.empty
                    |> SettingsState.addBoardConfirmed DefaultColumnNames.default
                    |> Expect.equal (SettingsState.ClosingPlugin Settings.default BoardConfigsForm.empty)
        , test "does nothing if ClosingSettings" <|
            \() ->
                SettingsState.ClosingSettings Settings.default BoardConfigsForm.empty
                    |> SettingsState.addBoardConfirmed DefaultColumnNames.default
                    |> Expect.equal (SettingsState.ClosingSettings Settings.default BoardConfigsForm.empty)
        , test "does nothing if DeletingBoard" <|
            \() ->
                SettingsState.DeletingBoard Settings.default BoardConfigsForm.empty
                    |> SettingsState.addBoardConfirmed DefaultColumnNames.default
                    |> Expect.equal (SettingsState.DeletingBoard Settings.default BoardConfigsForm.empty)
        , test "does nothing if DeletingColumn" <|
            \() ->
                SettingsState.DeletingColumn 1 Settings.default BoardConfigsForm.empty
                    |> SettingsState.addBoardConfirmed DefaultColumnNames.default
                    |> Expect.equal (SettingsState.DeletingColumn 1 Settings.default BoardConfigsForm.empty)
        , test "does nothing if EditingBoard" <|
            \() ->
                SettingsState.EditingBoard Settings.default BoardConfigsForm.empty
                    |> SettingsState.addBoardConfirmed DefaultColumnNames.default
                    |> Expect.equal (SettingsState.EditingBoard Settings.default BoardConfigsForm.empty)
        , test "does nothing if EditingGlobalSettings" <|
            \() ->
                SettingsState.EditingGlobalSettings Settings.default BoardConfigsForm.empty
                    |> SettingsState.addBoardConfirmed DefaultColumnNames.default
                    |> Expect.equal (SettingsState.EditingGlobalSettings Settings.default BoardConfigsForm.empty)
        ]


addBoardRequested : Test
addBoardRequested =
    describe "addBoardRequested"
        [ test "does nothing if already in AddingBoard state" <|
            \() ->
                SettingsState.AddingBoard NewBoardConfig.default Settings.default BoardConfigsForm.empty
                    |> SettingsState.addBoardRequested
                    |> Expect.equal (SettingsState.AddingBoard NewBoardConfig.default Settings.default BoardConfigsForm.empty)
        , test "AddingColumn -> AddingBoard" <|
            \() ->
                SettingsState.AddingColumn (NewColumnConfig "" "") Settings.default BoardConfigsForm.empty
                    |> SettingsState.addBoardRequested
                    |> Expect.equal (SettingsState.AddingBoard NewBoardConfig.default Settings.default BoardConfigsForm.empty)
        , test "ClosingPlugin -> AddingBoard" <|
            \() ->
                SettingsState.ClosingPlugin Settings.default BoardConfigsForm.empty
                    |> SettingsState.addBoardRequested
                    |> Expect.equal (SettingsState.AddingBoard NewBoardConfig.default Settings.default BoardConfigsForm.empty)
        , test "ClosingSettings -> AddingBoard" <|
            \() ->
                SettingsState.ClosingSettings Settings.default BoardConfigsForm.empty
                    |> SettingsState.addBoardRequested
                    |> Expect.equal (SettingsState.AddingBoard NewBoardConfig.default Settings.default BoardConfigsForm.empty)
        , test "DeletingBoard -> AddingBoard" <|
            \() ->
                SettingsState.DeletingBoard Settings.default BoardConfigsForm.empty
                    |> SettingsState.addBoardRequested
                    |> Expect.equal (SettingsState.AddingBoard NewBoardConfig.default Settings.default BoardConfigsForm.empty)
        , test "DeletingColumn -> AddingBoard" <|
            \() ->
                SettingsState.DeletingColumn 1 Settings.default BoardConfigsForm.empty
                    |> SettingsState.addBoardRequested
                    |> Expect.equal (SettingsState.AddingBoard NewBoardConfig.default Settings.default BoardConfigsForm.empty)
        , test "EditingBoard -> AddingBoard" <|
            \() ->
                SettingsState.EditingBoard Settings.default BoardConfigsForm.empty
                    |> SettingsState.addBoardRequested
                    |> Expect.equal (SettingsState.AddingBoard NewBoardConfig.default Settings.default BoardConfigsForm.empty)
        , test "EditingGlobalSettings -> AddingBoard" <|
            \() ->
                SettingsState.EditingGlobalSettings Settings.default BoardConfigsForm.empty
                    |> SettingsState.addBoardRequested
                    |> Expect.equal (SettingsState.AddingBoard NewBoardConfig.default Settings.default BoardConfigsForm.empty)
        ]


addColumnConfirmed : Test
addColumnConfirmed =
    describe "addColumnConfirmed"
        [ test "does nothing if AddingBoard" <|
            \() ->
                SettingsState.AddingBoard NewBoardConfig.default Settings.default BoardConfigsForm.empty
                    |> SettingsState.addColumnConfirmed
                    |> Expect.equal (SettingsState.AddingBoard NewBoardConfig.default Settings.default BoardConfigsForm.empty)
        , test "AddingColumn -> EditingBoard" <|
            \() ->
                SettingsState.AddingColumn (NewColumnConfig "" "") Settings.default BoardConfigsForm.empty
                    |> SettingsState.addColumnConfirmed
                    |> Expect.equal (SettingsState.EditingBoard Settings.default BoardConfigsForm.empty)
        , test "does nothing if ClosingPlugin" <|
            \() ->
                SettingsState.ClosingPlugin Settings.default BoardConfigsForm.empty
                    |> SettingsState.addColumnConfirmed
                    |> Expect.equal (SettingsState.ClosingPlugin Settings.default BoardConfigsForm.empty)
        , test "does nothing if ClosingSettings" <|
            \() ->
                SettingsState.ClosingSettings Settings.default BoardConfigsForm.empty
                    |> SettingsState.addColumnConfirmed
                    |> Expect.equal (SettingsState.ClosingSettings Settings.default BoardConfigsForm.empty)
        , test "does nothing if DeletingBoard" <|
            \() ->
                SettingsState.DeletingBoard Settings.default BoardConfigsForm.empty
                    |> SettingsState.addColumnConfirmed
                    |> Expect.equal (SettingsState.DeletingBoard Settings.default BoardConfigsForm.empty)
        , test "does nothing if DeletingColumn" <|
            \() ->
                SettingsState.DeletingColumn 1 Settings.default BoardConfigsForm.empty
                    |> SettingsState.addColumnConfirmed
                    |> Expect.equal (SettingsState.DeletingColumn 1 Settings.default BoardConfigsForm.empty)
        , test "does nothing if EditingBoard" <|
            \() ->
                SettingsState.EditingBoard Settings.default BoardConfigsForm.empty
                    |> SettingsState.addColumnConfirmed
                    |> Expect.equal (SettingsState.EditingBoard Settings.default BoardConfigsForm.empty)
        , test "does nothing if EditingGlobalSettings" <|
            \() ->
                SettingsState.EditingGlobalSettings Settings.default BoardConfigsForm.empty
                    |> SettingsState.addColumnConfirmed
                    |> Expect.equal (SettingsState.EditingGlobalSettings Settings.default BoardConfigsForm.empty)
        ]


addColumnRequested : Test
addColumnRequested =
    describe "addColumnRequested"
        [ test "AddingBoard -> AddingColumn" <|
            \() ->
                SettingsState.AddingBoard NewBoardConfig.default Settings.default BoardConfigsForm.empty
                    |> SettingsState.addColumnRequested
                    |> Expect.equal (SettingsState.AddingColumn (NewColumnConfig "" "completed") Settings.default BoardConfigsForm.empty)
        , test "the NewColumnConfig defaults to the first dropdown item" <|
            \() ->
                SettingsState.AddingBoard NewBoardConfig.default Settings.default BoardConfigsForm.empty
                    |> SettingsState.addColumnRequested
                    |> newColumnConfig
                    |> Maybe.map .columnType
                    |> Expect.equal (Just "completed")
        , test "does nothing if already in AddingColumn state" <|
            \() ->
                SettingsState.AddingBoard NewBoardConfig.default Settings.default BoardConfigsForm.empty
                    |> SettingsState.addColumnRequested
                    |> Expect.equal (SettingsState.AddingColumn (NewColumnConfig "" "completed") Settings.default BoardConfigsForm.empty)
        , test "ClosingPlugin -> AddingColumn" <|
            \() ->
                SettingsState.ClosingPlugin Settings.default BoardConfigsForm.empty
                    |> SettingsState.addColumnRequested
                    |> Expect.equal (SettingsState.AddingColumn (NewColumnConfig "" "completed") Settings.default BoardConfigsForm.empty)
        , test "ClosingSettings -> AddingColumn" <|
            \() ->
                SettingsState.ClosingSettings Settings.default BoardConfigsForm.empty
                    |> SettingsState.addColumnRequested
                    |> Expect.equal (SettingsState.AddingColumn (NewColumnConfig "" "completed") Settings.default BoardConfigsForm.empty)
        , test "DeletingBoard -> AddingColumn" <|
            \() ->
                SettingsState.DeletingBoard Settings.default BoardConfigsForm.empty
                    |> SettingsState.addColumnRequested
                    |> Expect.equal (SettingsState.AddingColumn (NewColumnConfig "" "completed") Settings.default BoardConfigsForm.empty)
        , test "DeletingColumn -> AddingColumn" <|
            \() ->
                SettingsState.DeletingColumn 1 Settings.default BoardConfigsForm.empty
                    |> SettingsState.addColumnRequested
                    |> Expect.equal (SettingsState.AddingColumn (NewColumnConfig "" "completed") Settings.default BoardConfigsForm.empty)
        , test "EditingBoard -> AddingColumn" <|
            \() ->
                SettingsState.EditingBoard Settings.default BoardConfigsForm.empty
                    |> SettingsState.addColumnRequested
                    |> Expect.equal (SettingsState.AddingColumn (NewColumnConfig "" "completed") Settings.default BoardConfigsForm.empty)
        , test "EditingGlobalSettings -> AddingColumn" <|
            \() ->
                SettingsState.EditingGlobalSettings Settings.default BoardConfigsForm.empty
                    |> SettingsState.addColumnRequested
                    |> Expect.equal (SettingsState.AddingColumn (NewColumnConfig "" "completed") Settings.default BoardConfigsForm.empty)
        ]


boardConfigs : Test
boardConfigs =
    describe "boardConfigs"
        [ test "returns the configs (apart from the one being added) if in AddingBoard state" <|
            \() ->
                SettingsState.AddingBoard NewBoardConfig.default (settingsFromBoardConfigs [ exampleBoardConfig ]) BoardConfigsForm.empty
                    |> SettingsState.boardConfigs
                    |> Expect.equal (SafeZipper.fromList [ exampleBoardConfig ])
        , test "returns the configs if in AddingColumn state" <|
            \() ->
                SettingsState.AddingColumn (NewColumnConfig "" "") (settingsFromBoardConfigs [ exampleBoardConfig ]) BoardConfigsForm.empty
                    |> SettingsState.boardConfigs
                    |> Expect.equal (SafeZipper.fromList [ exampleBoardConfig ])
        , test "returns the configs if in ClosingPlugin state" <|
            \() ->
                SettingsState.ClosingPlugin (settingsFromBoardConfigs [ exampleBoardConfig ]) BoardConfigsForm.empty
                    |> SettingsState.boardConfigs
                    |> Expect.equal (SafeZipper.fromList [ exampleBoardConfig ])
        , test "returns the configs if in ClosingSettings state" <|
            \() ->
                SettingsState.ClosingSettings (settingsFromBoardConfigs [ exampleBoardConfig ]) BoardConfigsForm.empty
                    |> SettingsState.boardConfigs
                    |> Expect.equal (SafeZipper.fromList [ exampleBoardConfig ])
        , test "returns the configs if in DeletingBoard state" <|
            \() ->
                SettingsState.DeletingBoard (settingsFromBoardConfigs [ exampleBoardConfig ]) BoardConfigsForm.empty
                    |> SettingsState.boardConfigs
                    |> Expect.equal (SafeZipper.fromList [ exampleBoardConfig ])
        , test "returns the configs if in DeletingColumn state" <|
            \() ->
                SettingsState.DeletingColumn 1 (settingsFromBoardConfigs [ exampleBoardConfig ]) BoardConfigsForm.empty
                    |> SettingsState.boardConfigs
                    |> Expect.equal (SafeZipper.fromList [ exampleBoardConfig ])
        , test "returns the configs if in EditingBoard state" <|
            \() ->
                SettingsState.EditingBoard (settingsFromBoardConfigs [ exampleBoardConfig ]) BoardConfigsForm.empty
                    |> SettingsState.boardConfigs
                    |> Expect.equal (SafeZipper.fromList [ exampleBoardConfig ])
        , test "returns the configs if in EditingGlobalSettings state" <|
            \() ->
                SettingsState.EditingGlobalSettings (settingsFromBoardConfigs [ exampleBoardConfig ]) BoardConfigsForm.empty
                    |> SettingsState.boardConfigs
                    |> Expect.equal (SafeZipper.fromList [ exampleBoardConfig ])
        ]


cancelCurrentState : Test
cancelCurrentState =
    describe "cancelCurrentState"
        [ test "AddingBoard -> ClosingPlugin if the board list is empty" <|
            \() ->
                SettingsState.AddingBoard NewBoardConfig.default Settings.default BoardConfigsForm.empty
                    |> SettingsState.cancelCurrentState
                    |> Expect.equal (SettingsState.ClosingPlugin Settings.default BoardConfigsForm.empty)
        , test "AddingBoard -> EditingBoard if the board list is NOT empty" <|
            \() ->
                SettingsState.AddingBoard NewBoardConfig.default (settingsFromBoardConfigs [ exampleBoardConfig ]) BoardConfigsForm.empty
                    |> SettingsState.cancelCurrentState
                    |> Expect.equal
                        (SettingsState.EditingBoard
                            (settingsFromBoardConfigs
                                [ exampleBoardConfig ]
                            )
                            { columnsForms =
                                SafeZipper.fromList
                                    [ { columnForms = [ ColumnForm.NamedTagColumnForm { name = "foo", tag = "bar" } ] } ]
                            }
                        )
        , test "AddingColumn -> EditingBoard" <|
            \() ->
                SettingsState.AddingColumn (NewColumnConfig "" "") (settingsFromBoardConfigs [ exampleBoardConfig ]) BoardConfigsForm.empty
                    |> SettingsState.cancelCurrentState
                    |> Expect.equal (SettingsState.EditingBoard (settingsFromBoardConfigs [ exampleBoardConfig ]) BoardConfigsForm.empty)
        , test "ClosingPlugin -> ClosingPlugin" <|
            \() ->
                SettingsState.ClosingPlugin Settings.default BoardConfigsForm.empty
                    |> SettingsState.cancelCurrentState
                    |> Expect.equal (SettingsState.ClosingPlugin Settings.default BoardConfigsForm.empty)
        , test "ClosingSettings -> ClosingSettings" <|
            \() ->
                SettingsState.ClosingSettings Settings.default BoardConfigsForm.empty
                    |> SettingsState.cancelCurrentState
                    |> Expect.equal (SettingsState.ClosingSettings Settings.default BoardConfigsForm.empty)
        , test "DeletingBoard -> EditingBoard" <|
            \() ->
                SettingsState.DeletingBoard Settings.default BoardConfigsForm.empty
                    |> SettingsState.cancelCurrentState
                    |> Expect.equal (SettingsState.EditingBoard Settings.default BoardConfigsForm.empty)
        , test "DeletingColumn -> EditingBoard" <|
            \() ->
                SettingsState.DeletingColumn 1 Settings.default BoardConfigsForm.empty
                    |> SettingsState.cancelCurrentState
                    |> Expect.equal (SettingsState.EditingBoard Settings.default BoardConfigsForm.empty)
        , test "EditingBoard -> ClosingSettings" <|
            \() ->
                SettingsState.EditingBoard Settings.default BoardConfigsForm.empty
                    |> SettingsState.cancelCurrentState
                    |> Expect.equal (SettingsState.ClosingSettings Settings.default BoardConfigsForm.empty)
        , test "EditingGlobalSettings -> ClosingSettings" <|
            \() ->
                SettingsState.EditingGlobalSettings Settings.default BoardConfigsForm.empty
                    |> SettingsState.cancelCurrentState
                    |> Expect.equal (SettingsState.ClosingSettings Settings.default BoardConfigsForm.empty)
        ]


deleteBoardRequested : Test
deleteBoardRequested =
    describe "deleteBoardRequested"
        [ test "AddingBoard -> DeletingBoard" <|
            \() ->
                SettingsState.AddingBoard NewBoardConfig.default Settings.default BoardConfigsForm.empty
                    |> SettingsState.deleteBoardRequested
                    |> Expect.equal (SettingsState.DeletingBoard Settings.default BoardConfigsForm.empty)
        , test "AddingColumn -> DeletingBoard" <|
            \() ->
                SettingsState.AddingColumn (NewColumnConfig "" "") Settings.default BoardConfigsForm.empty
                    |> SettingsState.deleteBoardRequested
                    |> Expect.equal (SettingsState.DeletingBoard Settings.default BoardConfigsForm.empty)
        , test "ClosingPlugin -> DeletingBoard" <|
            \() ->
                SettingsState.ClosingPlugin Settings.default BoardConfigsForm.empty
                    |> SettingsState.deleteBoardRequested
                    |> Expect.equal (SettingsState.DeletingBoard Settings.default BoardConfigsForm.empty)
        , test "ClosingSettings -> DeletingBoard" <|
            \() ->
                SettingsState.ClosingSettings Settings.default BoardConfigsForm.empty
                    |> SettingsState.deleteBoardRequested
                    |> Expect.equal (SettingsState.DeletingBoard Settings.default BoardConfigsForm.empty)
        , test "does nothing if already DeletingBoard" <|
            \() ->
                SettingsState.DeletingBoard Settings.default BoardConfigsForm.empty
                    |> SettingsState.deleteBoardRequested
                    |> Expect.equal (SettingsState.DeletingBoard Settings.default BoardConfigsForm.empty)
        , test "DeletingColumn -> DeletingBoard" <|
            \() ->
                SettingsState.DeletingColumn 1 Settings.default BoardConfigsForm.empty
                    |> SettingsState.deleteBoardRequested
                    |> Expect.equal (SettingsState.DeletingBoard Settings.default BoardConfigsForm.empty)
        , test "EditingBoard -> DeletingBoard" <|
            \() ->
                SettingsState.EditingBoard Settings.default BoardConfigsForm.empty
                    |> SettingsState.deleteBoardRequested
                    |> Expect.equal (SettingsState.DeletingBoard Settings.default BoardConfigsForm.empty)
        , test "EditingGlobalSettings -> DeletingBoard" <|
            \() ->
                SettingsState.EditingGlobalSettings Settings.default BoardConfigsForm.empty
                    |> SettingsState.deleteBoardRequested
                    |> Expect.equal (SettingsState.DeletingBoard Settings.default BoardConfigsForm.empty)
        ]


deleteColumnRequested : Test
deleteColumnRequested =
    describe "deleteColumnRequested"
        [ test "AddingBoard -> DeletingColumn" <|
            \() ->
                SettingsState.AddingBoard NewBoardConfig.default Settings.default BoardConfigsForm.empty
                    |> SettingsState.deleteColumnRequested 3
                    |> Expect.equal (SettingsState.DeletingColumn 3 Settings.default BoardConfigsForm.empty)
        , test "AddingColumn -> DeletingColumn" <|
            \() ->
                SettingsState.AddingColumn (NewColumnConfig "" "") Settings.default BoardConfigsForm.empty
                    |> SettingsState.deleteColumnRequested 3
                    |> Expect.equal (SettingsState.DeletingColumn 3 Settings.default BoardConfigsForm.empty)
        , test "ClosingPlugin -> DeletingColumn" <|
            \() ->
                SettingsState.ClosingPlugin Settings.default BoardConfigsForm.empty
                    |> SettingsState.deleteColumnRequested 3
                    |> Expect.equal (SettingsState.DeletingColumn 3 Settings.default BoardConfigsForm.empty)
        , test "ClosingSettings -> DeletingColumn" <|
            \() ->
                SettingsState.ClosingSettings Settings.default BoardConfigsForm.empty
                    |> SettingsState.deleteColumnRequested 3
                    |> Expect.equal (SettingsState.DeletingColumn 3 Settings.default BoardConfigsForm.empty)
        , test "DeletingBoard -> DeletingColumn" <|
            \() ->
                SettingsState.DeletingBoard Settings.default BoardConfigsForm.empty
                    |> SettingsState.deleteColumnRequested 3
                    |> Expect.equal (SettingsState.DeletingColumn 3 Settings.default BoardConfigsForm.empty)
        , test "ensure deleting the given column if already in DeletingColumn state" <|
            \() ->
                SettingsState.DeletingColumn 2 Settings.default BoardConfigsForm.empty
                    |> SettingsState.deleteColumnRequested 3
                    |> Expect.equal (SettingsState.DeletingColumn 3 Settings.default BoardConfigsForm.empty)
        , test "EditingBoard -> DeletingColumn" <|
            \() ->
                SettingsState.EditingBoard Settings.default BoardConfigsForm.empty
                    |> SettingsState.deleteColumnRequested 3
                    |> Expect.equal (SettingsState.DeletingColumn 3 Settings.default BoardConfigsForm.empty)
        , test "EditingGlobalSettings -> DeletingColumn" <|
            \() ->
                SettingsState.EditingGlobalSettings Settings.default BoardConfigsForm.empty
                    |> SettingsState.deleteColumnRequested 3
                    |> Expect.equal (SettingsState.DeletingColumn 3 Settings.default BoardConfigsForm.empty)
        ]


deleteConfirmed : Test
deleteConfirmed =
    describe "deleteConfirmed"
        [ test "does nothing if AddingBoard" <|
            \() ->
                SettingsState.AddingBoard NewBoardConfig.default Settings.default BoardConfigsForm.empty
                    |> SettingsState.deleteConfirmed
                    |> Expect.equal (SettingsState.AddingBoard NewBoardConfig.default Settings.default BoardConfigsForm.empty)
        , test "does nothing if AddingColumn" <|
            \() ->
                SettingsState.AddingColumn (NewColumnConfig "" "") Settings.default BoardConfigsForm.empty
                    |> SettingsState.deleteConfirmed
                    |> Expect.equal (SettingsState.AddingColumn (NewColumnConfig "" "") Settings.default BoardConfigsForm.empty)
        , test "does nothing if ClosingPlugin" <|
            \() ->
                SettingsState.ClosingPlugin Settings.default BoardConfigsForm.empty
                    |> SettingsState.deleteConfirmed
                    |> Expect.equal (SettingsState.ClosingPlugin Settings.default BoardConfigsForm.empty)
        , test "does nothing if ClosingSettings" <|
            \() ->
                SettingsState.ClosingSettings Settings.default BoardConfigsForm.empty
                    |> SettingsState.deleteConfirmed
                    |> Expect.equal (SettingsState.ClosingSettings Settings.default BoardConfigsForm.empty)
        , test "deletes the current board and -> Adding if DeletingBoard and there is ONLY one board" <|
            \() ->
                SettingsState.DeletingBoard (settingsFromBoardConfigs [ exampleBoardConfig ]) BoardConfigsForm.empty
                    |> SettingsState.deleteConfirmed
                    |> Expect.equal (SettingsState.AddingBoard NewBoardConfig.default Settings.default BoardConfigsForm.empty)
        , test "deletes the current board and -> EditingBoard if DeletingBoard and there is MORE THAN one board" <|
            \() ->
                SettingsState.DeletingBoard
                    (settingsFromBoardConfigsWithIndex 1
                        [ exampleBoardConfigNoColumns, exampleBoardConfig, exampleBoardConfigNoColumns ]
                    )
                    BoardConfigsForm.empty
                    |> SettingsState.deleteConfirmed
                    |> Expect.equal
                        (SettingsState.EditingBoard
                            (settingsFromBoardConfigsWithIndex 1 [ exampleBoardConfigNoColumns, exampleBoardConfigNoColumns ])
                            { columnsForms =
                                SafeZipper.fromList
                                    [ { columnForms = [] }
                                    , { columnForms = [] }
                                    ]
                                    |> SafeZipper.atIndex 1
                            }
                        )
        , test "deletes the current column and -> EditingBoard if DeletingColumn" <|
            \() ->
                let
                    result =
                        SafeZipper.fromList
                            [ BoardConfig.fromNewBoardConfig DefaultColumnNames.default (NewBoardConfig "foo" "emptyBoard")
                            , BoardConfig.fromNewBoardConfig DefaultColumnNames.default (NewBoardConfig "baz" "tagBoard")
                                |> BoardConfig.deleteColumn 1
                            ]
                            |> SafeZipper.atIndex 1
                            |> BoardConfigsForm.init
                in
                SettingsState.DeletingColumn 1 (settingsFromBoardConfigs [ exampleBoardConfig ]) exampleBoardConfigsForm
                    |> SettingsState.deleteConfirmed
                    |> Expect.equal (SettingsState.EditingBoard (settingsFromBoardConfigs [ exampleBoardConfig ]) result)
        , test "does nothing if EditingBoard" <|
            \() ->
                SettingsState.EditingBoard Settings.default BoardConfigsForm.empty
                    |> SettingsState.deleteConfirmed
                    |> Expect.equal (SettingsState.EditingBoard Settings.default BoardConfigsForm.empty)
        , test "does nothing if EditingGlobalSettings" <|
            \() ->
                SettingsState.EditingGlobalSettings Settings.default BoardConfigsForm.empty
                    |> SettingsState.deleteConfirmed
                    |> Expect.equal (SettingsState.EditingGlobalSettings Settings.default BoardConfigsForm.empty)
        ]


editBoardAt : Test
editBoardAt =
    describe "editBoardAt"
        [ test "AddingBoard -> EditingBoard" <|
            \() ->
                SettingsState.AddingBoard
                    NewBoardConfig.default
                    (settingsFromBoardConfigsWithIndex 0 [ exampleBoardConfigNoColumns, exampleBoardConfig ])
                    { columnsForms =
                        SafeZipper.fromList
                            [ { columnForms = [] }
                            , { columnForms = [ ColumnForm.NamedTagColumnForm { name = "foo", tag = "bar" } ] }
                            ]
                    }
                    |> SettingsState.editBoardAt 1
                    |> Expect.equal
                        (SettingsState.EditingBoard
                            (settingsFromBoardConfigsWithIndex 1 [ exampleBoardConfigNoColumns, exampleBoardConfig ])
                            { columnsForms =
                                SafeZipper.fromList
                                    [ { columnForms = [] }
                                    , { columnForms = [ ColumnForm.NamedTagColumnForm { name = "foo", tag = "bar" } ] }
                                    ]
                                    |> SafeZipper.atIndex 1
                            }
                        )
        , test "AddingColumn -> EditingBoard" <|
            \() ->
                SettingsState.AddingColumn
                    (NewColumnConfig "" "")
                    (settingsFromBoardConfigsWithIndex 0 [ exampleBoardConfigNoColumns, exampleBoardConfig ])
                    { columnsForms =
                        SafeZipper.fromList
                            [ { columnForms = [] }
                            , { columnForms = [ ColumnForm.NamedTagColumnForm { name = "foo", tag = "bar" } ] }
                            ]
                    }
                    |> SettingsState.editBoardAt 1
                    |> Expect.equal
                        (SettingsState.EditingBoard
                            (settingsFromBoardConfigsWithIndex 1 [ exampleBoardConfigNoColumns, exampleBoardConfig ])
                            { columnsForms =
                                SafeZipper.fromList
                                    [ { columnForms = [] }
                                    , { columnForms = [ ColumnForm.NamedTagColumnForm { name = "foo", tag = "bar" } ] }
                                    ]
                                    |> SafeZipper.atIndex 1
                            }
                        )
        , test "ClosingPlugin -> EditingBoard" <|
            \() ->
                SettingsState.ClosingPlugin
                    (settingsFromBoardConfigsWithIndex 0 [ exampleBoardConfigNoColumns, exampleBoardConfig ])
                    { columnsForms =
                        SafeZipper.fromList
                            [ { columnForms = [] }
                            , { columnForms = [ ColumnForm.NamedTagColumnForm { name = "foo", tag = "bar" } ] }
                            ]
                    }
                    |> SettingsState.editBoardAt 1
                    |> Expect.equal
                        (SettingsState.EditingBoard
                            (settingsFromBoardConfigsWithIndex 1 [ exampleBoardConfigNoColumns, exampleBoardConfig ])
                            { columnsForms =
                                SafeZipper.fromList
                                    [ { columnForms = [] }
                                    , { columnForms = [ ColumnForm.NamedTagColumnForm { name = "foo", tag = "bar" } ] }
                                    ]
                                    |> SafeZipper.atIndex 1
                            }
                        )
        , test "ClosingSettings -> EditingBoard" <|
            \() ->
                SettingsState.ClosingSettings
                    (settingsFromBoardConfigsWithIndex 0 [ exampleBoardConfigNoColumns, exampleBoardConfig ])
                    { columnsForms =
                        SafeZipper.fromList
                            [ { columnForms = [] }
                            , { columnForms = [ ColumnForm.NamedTagColumnForm { name = "foo", tag = "bar" } ] }
                            ]
                    }
                    |> SettingsState.editBoardAt 1
                    |> Expect.equal
                        (SettingsState.EditingBoard
                            (settingsFromBoardConfigsWithIndex 1 [ exampleBoardConfigNoColumns, exampleBoardConfig ])
                            { columnsForms =
                                SafeZipper.fromList
                                    [ { columnForms = [] }
                                    , { columnForms = [ ColumnForm.NamedTagColumnForm { name = "foo", tag = "bar" } ] }
                                    ]
                                    |> SafeZipper.atIndex 1
                            }
                        )
        , test "DeletingBoard -> EditingBoard" <|
            \() ->
                SettingsState.DeletingBoard
                    (settingsFromBoardConfigsWithIndex 0 [ exampleBoardConfigNoColumns, exampleBoardConfig ])
                    { columnsForms =
                        SafeZipper.fromList
                            [ { columnForms = [] }
                            , { columnForms = [ ColumnForm.NamedTagColumnForm { name = "foo", tag = "bar" } ] }
                            ]
                    }
                    |> SettingsState.editBoardAt 1
                    |> Expect.equal
                        (SettingsState.EditingBoard
                            (settingsFromBoardConfigsWithIndex 1 [ exampleBoardConfigNoColumns, exampleBoardConfig ])
                            { columnsForms =
                                SafeZipper.fromList
                                    [ { columnForms = [] }
                                    , { columnForms = [ ColumnForm.NamedTagColumnForm { name = "foo", tag = "bar" } ] }
                                    ]
                                    |> SafeZipper.atIndex 1
                            }
                        )
        , test "DeletingColumn -> EditingBoard" <|
            \() ->
                SettingsState.DeletingColumn
                    1
                    (settingsFromBoardConfigsWithIndex 0 [ exampleBoardConfigNoColumns, exampleBoardConfig ])
                    { columnsForms =
                        SafeZipper.fromList
                            [ { columnForms = [] }
                            , { columnForms = [ ColumnForm.NamedTagColumnForm { name = "foo", tag = "bar" } ] }
                            ]
                    }
                    |> SettingsState.editBoardAt 1
                    |> Expect.equal
                        (SettingsState.EditingBoard
                            (settingsFromBoardConfigsWithIndex 1 [ exampleBoardConfigNoColumns, exampleBoardConfig ])
                            { columnsForms =
                                SafeZipper.fromList
                                    [ { columnForms = [] }
                                    , { columnForms = [ ColumnForm.NamedTagColumnForm { name = "foo", tag = "bar" } ] }
                                    ]
                                    |> SafeZipper.atIndex 1
                            }
                        )
        , test "EditingBoard -> EditingBoard (switched)" <|
            \() ->
                SettingsState.EditingBoard
                    (settingsFromBoardConfigsWithIndex 0 [ exampleBoardConfigNoColumns, exampleBoardConfig ])
                    { columnsForms =
                        SafeZipper.fromList
                            [ { columnForms = [] }
                            , { columnForms = [ ColumnForm.NamedTagColumnForm { name = "foo", tag = "bar" } ] }
                            ]
                    }
                    |> SettingsState.editBoardAt 1
                    |> Expect.equal
                        (SettingsState.EditingBoard
                            (settingsFromBoardConfigsWithIndex 1 [ exampleBoardConfigNoColumns, exampleBoardConfig ])
                            { columnsForms =
                                SafeZipper.fromList
                                    [ { columnForms = [] }
                                    , { columnForms = [ ColumnForm.NamedTagColumnForm { name = "foo", tag = "bar" } ] }
                                    ]
                                    |> SafeZipper.atIndex 1
                            }
                        )
        , test "EditingGlobalSettings -> EditingBoard" <|
            \() ->
                SettingsState.EditingGlobalSettings
                    (settingsFromBoardConfigsWithIndex 0 [ exampleBoardConfigNoColumns, exampleBoardConfig ])
                    { columnsForms =
                        SafeZipper.fromList
                            [ { columnForms = [] }
                            , { columnForms = [ ColumnForm.NamedTagColumnForm { name = "foo", tag = "bar" } ] }
                            ]
                    }
                    |> SettingsState.editBoardAt 1
                    |> Expect.equal
                        (SettingsState.EditingBoard
                            (settingsFromBoardConfigsWithIndex 1 [ exampleBoardConfigNoColumns, exampleBoardConfig ])
                            { columnsForms =
                                SafeZipper.fromList
                                    [ { columnForms = [] }
                                    , { columnForms = [ ColumnForm.NamedTagColumnForm { name = "foo", tag = "bar" } ] }
                                    ]
                                    |> SafeZipper.atIndex 1
                            }
                        )
        ]


editGlobalSettings : Test
editGlobalSettings =
    describe "editGlobalSettings"
        [ test "AddingBoard -> EditingGlobalSettings" <|
            \() ->
                SettingsState.AddingBoard NewBoardConfig.default Settings.default BoardConfigsForm.empty
                    |> SettingsState.editGlobalSettings
                    |> Expect.equal (SettingsState.EditingGlobalSettings Settings.default BoardConfigsForm.empty)
        , test "AddingColumn -> EditingGlobalSettings" <|
            \() ->
                SettingsState.AddingColumn (NewColumnConfig "" "") Settings.default BoardConfigsForm.empty
                    |> SettingsState.editGlobalSettings
                    |> Expect.equal (SettingsState.EditingGlobalSettings Settings.default BoardConfigsForm.empty)
        , test "ClosingPlugin -> EditingGlobalSettings" <|
            \() ->
                SettingsState.ClosingPlugin Settings.default BoardConfigsForm.empty
                    |> SettingsState.editGlobalSettings
                    |> Expect.equal (SettingsState.EditingGlobalSettings Settings.default BoardConfigsForm.empty)
        , test "ClosingSettings -> EditingGlobalSettings" <|
            \() ->
                SettingsState.ClosingSettings Settings.default BoardConfigsForm.empty
                    |> SettingsState.editGlobalSettings
                    |> Expect.equal (SettingsState.EditingGlobalSettings Settings.default BoardConfigsForm.empty)
        , test "DeletingBoard -> EditingGlobalSettings" <|
            \() ->
                SettingsState.DeletingBoard Settings.default BoardConfigsForm.empty
                    |> SettingsState.editGlobalSettings
                    |> Expect.equal (SettingsState.EditingGlobalSettings Settings.default BoardConfigsForm.empty)
        , test "DeletingColumn -> EditingGlobalSettings" <|
            \() ->
                SettingsState.DeletingColumn 1 Settings.default BoardConfigsForm.empty
                    |> SettingsState.editGlobalSettings
                    |> Expect.equal (SettingsState.EditingGlobalSettings Settings.default BoardConfigsForm.empty)
        , test "EditingBoard -> EditingGlobalSettings" <|
            \() ->
                SettingsState.EditingBoard Settings.default BoardConfigsForm.empty
                    |> SettingsState.editGlobalSettings
                    |> Expect.equal (SettingsState.EditingGlobalSettings Settings.default BoardConfigsForm.empty)
        , test "does nothing to EditingGlobalSettings" <|
            \() ->
                SettingsState.EditingGlobalSettings Settings.default BoardConfigsForm.empty
                    |> SettingsState.editGlobalSettings
                    |> Expect.equal (SettingsState.EditingGlobalSettings Settings.default BoardConfigsForm.empty)
        ]


init : Test
init =
    describe "init"
        [ test "returns AddingBoard with the default BoardConfig if there are no existing board configs" <|
            \() ->
                SettingsState.init Settings.default
                    |> Expect.equal
                        (SettingsState.AddingBoard
                            NewBoardConfig.default
                            Settings.default
                            BoardConfigsForm.empty
                        )
        , test "returns EditingBoard boardConfig" <|
            \() ->
                SettingsState.init (settingsFromBoardConfigs [ exampleBoardConfigNoColumns ])
                    |> Expect.equal
                        (SettingsState.EditingBoard
                            (settingsFromBoardConfigs [ exampleBoardConfigNoColumns ])
                            { columnsForms = SafeZipper.fromList [ { columnForms = [] } ] }
                        )
        , test "returns the BoardConfigsForm built from the currently selected board" <|
            \() ->
                let
                    settings =
                        settingsFromBoardConfigs [ exampleBoardConfigNoColumns, exampleBoardConfigMultiColumns, exampleBoardConfig ]
                            |> Settings.switchToBoard 1
                in
                SettingsState.init settings
                    |> Expect.equal
                        (SettingsState.EditingBoard
                            settings
                            { columnsForms =
                                SafeZipper.fromList
                                    [ { columnForms = [] }
                                    , { columnForms =
                                            [ ColumnForm.NamedTagColumnForm { name = "named", tag = "aTag" }
                                            , ColumnForm.UntaggedColumnForm { name = "untagged" }
                                            , ColumnForm.CompletedColumnForm { name = "completed", limit = "5" }
                                            ]
                                      }
                                    , { columnForms = [ ColumnForm.NamedTagColumnForm { name = "foo", tag = "bar" } ] }
                                    ]
                                    |> SafeZipper.atIndex 1
                            }
                        )
        ]


mapBoardBeingAdded : Test
mapBoardBeingAdded =
    describe "mapBoardBeingAdded"
        [ test "maps the board being added if it is in the AddingBoard state" <|
            \() ->
                SettingsState.AddingBoard NewBoardConfig.default Settings.default BoardConfigsForm.empty
                    |> SettingsState.mapBoardBeingAdded (always exampleNewBoardConfig)
                    |> Expect.equal (SettingsState.AddingBoard exampleNewBoardConfig Settings.default BoardConfigsForm.empty)
        , test "does nothing if it is in the AddingColumn state" <|
            \() ->
                SettingsState.AddingColumn (NewColumnConfig "" "") Settings.default BoardConfigsForm.empty
                    |> SettingsState.mapBoardBeingAdded (always exampleNewBoardConfig)
                    |> Expect.equal (SettingsState.AddingColumn (NewColumnConfig "" "") Settings.default BoardConfigsForm.empty)
        , test "does nothing if it is in the ClosingPlugin state" <|
            \() ->
                SettingsState.ClosingPlugin Settings.default BoardConfigsForm.empty
                    |> SettingsState.mapBoardBeingAdded (always exampleNewBoardConfig)
                    |> Expect.equal (SettingsState.ClosingPlugin Settings.default BoardConfigsForm.empty)
        , test "does nothing if it is in the ClosingSettings state" <|
            \() ->
                SettingsState.ClosingSettings Settings.default BoardConfigsForm.empty
                    |> SettingsState.mapBoardBeingAdded (always exampleNewBoardConfig)
                    |> Expect.equal (SettingsState.ClosingSettings Settings.default BoardConfigsForm.empty)
        , test "does nothing if it is in the DeletingBoard state" <|
            \() ->
                SettingsState.DeletingBoard Settings.default BoardConfigsForm.empty
                    |> SettingsState.mapBoardBeingAdded (always exampleNewBoardConfig)
                    |> Expect.equal (SettingsState.DeletingBoard Settings.default BoardConfigsForm.empty)
        , test "does nothing if it is in the DeletingColumn state" <|
            \() ->
                SettingsState.DeletingColumn 1 Settings.default BoardConfigsForm.empty
                    |> SettingsState.mapBoardBeingAdded (always exampleNewBoardConfig)
                    |> Expect.equal (SettingsState.DeletingColumn 1 Settings.default BoardConfigsForm.empty)
        , test "does nothing if it is in the EditingBoard state" <|
            \() ->
                SettingsState.EditingBoard Settings.default BoardConfigsForm.empty
                    |> SettingsState.mapBoardBeingAdded (always exampleNewBoardConfig)
                    |> Expect.equal (SettingsState.EditingBoard Settings.default BoardConfigsForm.empty)
        , test "does nothing if it is in the EditingGlobalSettings state" <|
            \() ->
                SettingsState.EditingGlobalSettings Settings.default BoardConfigsForm.empty
                    |> SettingsState.mapBoardBeingAdded (always exampleNewBoardConfig)
                    |> Expect.equal (SettingsState.EditingGlobalSettings Settings.default BoardConfigsForm.empty)
        ]


mapBoardBeingEdited : Test
mapBoardBeingEdited =
    describe "mapBoardBeingEdited"
        [ test "does nothing if it is in the AddingBoard state" <|
            \() ->
                SettingsState.AddingBoard NewBoardConfig.default (settingsFromBoardConfigs [ exampleBoardConfigNoColumns, exampleBoardConfig ]) BoardConfigsForm.empty
                    |> SettingsState.mapBoardBeingEdited (always exampleBoardConfig)
                    |> Expect.equal (SettingsState.AddingBoard NewBoardConfig.default (settingsFromBoardConfigs [ exampleBoardConfigNoColumns, exampleBoardConfig ]) BoardConfigsForm.empty)
        , test "does nothing if it is in the AddingColumn state" <|
            \() ->
                SettingsState.AddingColumn (NewColumnConfig "" "") (settingsFromBoardConfigs [ exampleBoardConfigNoColumns, exampleBoardConfig ]) BoardConfigsForm.empty
                    |> SettingsState.mapBoardBeingEdited (always exampleBoardConfig)
                    |> Expect.equal (SettingsState.AddingColumn (NewColumnConfig "" "") (settingsFromBoardConfigs [ exampleBoardConfigNoColumns, exampleBoardConfig ]) BoardConfigsForm.empty)
        , test "does nothing if it is in the ClosingPlugin state" <|
            \() ->
                SettingsState.ClosingPlugin (settingsFromBoardConfigs [ exampleBoardConfigNoColumns, exampleBoardConfig ]) BoardConfigsForm.empty
                    |> SettingsState.mapBoardBeingEdited (always exampleBoardConfig)
                    |> Expect.equal (SettingsState.ClosingPlugin (settingsFromBoardConfigs [ exampleBoardConfigNoColumns, exampleBoardConfig ]) BoardConfigsForm.empty)
        , test "does nothing if it is in the ClosingSettings state" <|
            \() ->
                SettingsState.ClosingSettings (settingsFromBoardConfigs [ exampleBoardConfigNoColumns, exampleBoardConfig ]) BoardConfigsForm.empty
                    |> SettingsState.mapBoardBeingEdited (always exampleBoardConfig)
                    |> Expect.equal (SettingsState.ClosingSettings (settingsFromBoardConfigs [ exampleBoardConfigNoColumns, exampleBoardConfig ]) BoardConfigsForm.empty)
        , test "does nothing if it is in the DeletingBoard state" <|
            \() ->
                SettingsState.DeletingBoard (settingsFromBoardConfigs [ exampleBoardConfigNoColumns, exampleBoardConfig ]) BoardConfigsForm.empty
                    |> SettingsState.mapBoardBeingEdited (always exampleBoardConfig)
                    |> Expect.equal (SettingsState.DeletingBoard (settingsFromBoardConfigs [ exampleBoardConfigNoColumns, exampleBoardConfig ]) BoardConfigsForm.empty)
        , test "does nothing if it is in the DeletingColumn state" <|
            \() ->
                SettingsState.DeletingColumn 1 (settingsFromBoardConfigs [ exampleBoardConfigNoColumns, exampleBoardConfig ]) BoardConfigsForm.empty
                    |> SettingsState.mapBoardBeingEdited (always exampleBoardConfig)
                    |> Expect.equal (SettingsState.DeletingColumn 1 (settingsFromBoardConfigs [ exampleBoardConfigNoColumns, exampleBoardConfig ]) BoardConfigsForm.empty)
        , test "updates the current board if it is in the EditingBoard state" <|
            \() ->
                SettingsState.EditingBoard (settingsFromBoardConfigs [ exampleBoardConfigNoColumns, exampleBoardConfig ]) BoardConfigsForm.empty
                    |> SettingsState.mapBoardBeingEdited (always exampleBoardConfig)
                    |> Expect.equal (SettingsState.EditingBoard (settingsFromBoardConfigs [ exampleBoardConfig, exampleBoardConfig ]) BoardConfigsForm.empty)
        , test "does nothing if it is in the EditingGlobalSettings state" <|
            \() ->
                SettingsState.EditingGlobalSettings (settingsFromBoardConfigs [ exampleBoardConfigNoColumns, exampleBoardConfig ]) BoardConfigsForm.empty
                    |> SettingsState.mapBoardBeingEdited (always exampleBoardConfig)
                    |> Expect.equal (SettingsState.EditingGlobalSettings (settingsFromBoardConfigs [ exampleBoardConfigNoColumns, exampleBoardConfig ]) BoardConfigsForm.empty)
        ]


mapCurrentColumnsForm : Test
mapCurrentColumnsForm =
    describe "mapCurrentColumnsForm"
        [ test "does nothing if it is in the AddingBoard state" <|
            \() ->
                SettingsState.AddingBoard NewBoardConfig.default (settingsFromBoardConfigs [ exampleBoardConfigNoColumns, exampleBoardConfig ]) exampleBoardConfigsForm
                    |> SettingsState.mapCurrentColumnsForm identity
                    |> Expect.equal (SettingsState.AddingBoard NewBoardConfig.default (settingsFromBoardConfigs [ exampleBoardConfigNoColumns, exampleBoardConfig ]) exampleBoardConfigsForm)
        , test "does nothing if it is in the AddingColumn state" <|
            \() ->
                SettingsState.AddingColumn (NewColumnConfig "" "") (settingsFromBoardConfigs [ exampleBoardConfigNoColumns, exampleBoardConfig ]) exampleBoardConfigsForm
                    |> SettingsState.mapCurrentColumnsForm identity
                    |> Expect.equal (SettingsState.AddingColumn (NewColumnConfig "" "") (settingsFromBoardConfigs [ exampleBoardConfigNoColumns, exampleBoardConfig ]) exampleBoardConfigsForm)
        , test "does nothing if it is in the ClosingPlugin state" <|
            \() ->
                SettingsState.ClosingPlugin (settingsFromBoardConfigs [ exampleBoardConfigNoColumns, exampleBoardConfig ]) exampleBoardConfigsForm
                    |> SettingsState.mapCurrentColumnsForm identity
                    |> Expect.equal (SettingsState.ClosingPlugin (settingsFromBoardConfigs [ exampleBoardConfigNoColumns, exampleBoardConfig ]) exampleBoardConfigsForm)
        , test "does nothing if it is in the ClosingSettings state" <|
            \() ->
                SettingsState.ClosingSettings (settingsFromBoardConfigs [ exampleBoardConfigNoColumns, exampleBoardConfig ]) exampleBoardConfigsForm
                    |> SettingsState.mapCurrentColumnsForm identity
                    |> Expect.equal (SettingsState.ClosingSettings (settingsFromBoardConfigs [ exampleBoardConfigNoColumns, exampleBoardConfig ]) exampleBoardConfigsForm)
        , test "does nothing if it is in the DeletingBoard state" <|
            \() ->
                SettingsState.DeletingBoard (settingsFromBoardConfigs [ exampleBoardConfigNoColumns, exampleBoardConfig ]) exampleBoardConfigsForm
                    |> SettingsState.mapCurrentColumnsForm identity
                    |> Expect.equal (SettingsState.DeletingBoard (settingsFromBoardConfigs [ exampleBoardConfigNoColumns, exampleBoardConfig ]) exampleBoardConfigsForm)
        , test "does nothing if it is in the DeletingColumn state" <|
            \() ->
                SettingsState.DeletingColumn 1 (settingsFromBoardConfigs [ exampleBoardConfigNoColumns, exampleBoardConfig ]) exampleBoardConfigsForm
                    |> SettingsState.mapCurrentColumnsForm identity
                    |> Expect.equal (SettingsState.DeletingColumn 1 (settingsFromBoardConfigs [ exampleBoardConfigNoColumns, exampleBoardConfig ]) exampleBoardConfigsForm)
        , test "updates the current board if it is in the EditingBoard state" <|
            \() ->
                SettingsState.EditingBoard (settingsFromBoardConfigs [ exampleBoardConfig, exampleBoardConfigNoColumns ]) exampleBoardConfigsForm
                    |> SettingsState.mapCurrentColumnsForm (always ColumnsForm.empty)
                    |> Expect.equal (SettingsState.EditingBoard (settingsFromBoardConfigs [ exampleBoardConfig, exampleBoardConfigNoColumns ]) exampleBoardConfigsFormEmpty)
        , test "does nothing if it is in the EditingGlobalSettings state" <|
            \() ->
                SettingsState.EditingGlobalSettings (settingsFromBoardConfigs [ exampleBoardConfigNoColumns, exampleBoardConfig ]) exampleBoardConfigsForm
                    |> SettingsState.mapCurrentColumnsForm identity
                    |> Expect.equal (SettingsState.EditingGlobalSettings (settingsFromBoardConfigs [ exampleBoardConfigNoColumns, exampleBoardConfig ]) exampleBoardConfigsForm)
        ]


mapColumnBeingAdded : Test
mapColumnBeingAdded =
    describe "mapColumnBeingAdded"
        [ test "does nothing if it is in the AddingBoard state" <|
            \() ->
                SettingsState.AddingBoard NewBoardConfig.default Settings.default BoardConfigsForm.empty
                    |> SettingsState.mapColumnBeingAdded (always exampleNewColumnConfig)
                    |> Expect.equal (SettingsState.AddingBoard NewBoardConfig.default Settings.default BoardConfigsForm.empty)
        , test "maps the board being added if it is in the AddingColumn state" <|
            \() ->
                SettingsState.AddingColumn (NewColumnConfig "" "") Settings.default BoardConfigsForm.empty
                    |> SettingsState.mapColumnBeingAdded (always <| NewColumnConfig "a" "b")
                    |> Expect.equal (SettingsState.AddingColumn (NewColumnConfig "a" "b") Settings.default BoardConfigsForm.empty)
        , test "does nothing if it is in the ClosingPlugin state" <|
            \() ->
                SettingsState.ClosingPlugin Settings.default BoardConfigsForm.empty
                    |> SettingsState.mapColumnBeingAdded (always exampleNewColumnConfig)
                    |> Expect.equal (SettingsState.ClosingPlugin Settings.default BoardConfigsForm.empty)
        , test "does nothing if it is in the ClosingSettings state" <|
            \() ->
                SettingsState.ClosingSettings Settings.default BoardConfigsForm.empty
                    |> SettingsState.mapColumnBeingAdded (always exampleNewColumnConfig)
                    |> Expect.equal (SettingsState.ClosingSettings Settings.default BoardConfigsForm.empty)
        , test "does nothing if it is in the DeletingBoard state" <|
            \() ->
                SettingsState.DeletingBoard Settings.default BoardConfigsForm.empty
                    |> SettingsState.mapColumnBeingAdded (always exampleNewColumnConfig)
                    |> Expect.equal (SettingsState.DeletingBoard Settings.default BoardConfigsForm.empty)
        , test "does nothing if it is in the DeletingColumn state" <|
            \() ->
                SettingsState.DeletingColumn 1 Settings.default BoardConfigsForm.empty
                    |> SettingsState.mapColumnBeingAdded (always exampleNewColumnConfig)
                    |> Expect.equal (SettingsState.DeletingColumn 1 Settings.default BoardConfigsForm.empty)
        , test "does nothing if it is in the EditingBoard state" <|
            \() ->
                SettingsState.EditingBoard Settings.default BoardConfigsForm.empty
                    |> SettingsState.mapColumnBeingAdded (always exampleNewColumnConfig)
                    |> Expect.equal (SettingsState.EditingBoard Settings.default BoardConfigsForm.empty)
        , test "does nothing if it is in the EditingGlobalSettings state" <|
            \() ->
                SettingsState.EditingGlobalSettings Settings.default BoardConfigsForm.empty
                    |> SettingsState.mapColumnBeingAdded (always exampleNewColumnConfig)
                    |> Expect.equal (SettingsState.EditingGlobalSettings Settings.default BoardConfigsForm.empty)
        ]


mapGlobalSettings : Test
mapGlobalSettings =
    describe "mapGlobalSettings"
        [ test "does nothing if it is in the AddingBoard state" <|
            \() ->
                SettingsState.AddingBoard (NewBoardConfig "" "") Settings.default BoardConfigsForm.empty
                    |> SettingsState.mapGlobalSettings (always exampleGlobalSettings)
                    |> SettingsState.settings
                    |> Settings.globalSettings
                    |> Expect.equal GlobalSettings.default
        , test "does nothing if it is in the AddingColumn state" <|
            \() ->
                SettingsState.AddingColumn (NewColumnConfig "" "") Settings.default BoardConfigsForm.empty
                    |> SettingsState.mapGlobalSettings (always exampleGlobalSettings)
                    |> SettingsState.settings
                    |> Settings.globalSettings
                    |> Expect.equal GlobalSettings.default
        , test "does nothing if it is in the ClosingPlugin state" <|
            \() ->
                SettingsState.ClosingPlugin Settings.default BoardConfigsForm.empty
                    |> SettingsState.mapGlobalSettings (always exampleGlobalSettings)
                    |> SettingsState.settings
                    |> Settings.globalSettings
                    |> Expect.equal GlobalSettings.default
        , test "does nothing if it is in the ClosingSettings state" <|
            \() ->
                SettingsState.ClosingSettings Settings.default BoardConfigsForm.empty
                    |> SettingsState.mapGlobalSettings (always exampleGlobalSettings)
                    |> SettingsState.settings
                    |> Settings.globalSettings
                    |> Expect.equal GlobalSettings.default
        , test "does nothing if it is in the DeletingBoard state" <|
            \() ->
                SettingsState.DeletingBoard Settings.default BoardConfigsForm.empty
                    |> SettingsState.mapGlobalSettings (always exampleGlobalSettings)
                    |> SettingsState.settings
                    |> Settings.globalSettings
                    |> Expect.equal GlobalSettings.default
        , test "does nothing if it is in the DeletingColumn state" <|
            \() ->
                SettingsState.DeletingColumn 1 Settings.default BoardConfigsForm.empty
                    |> SettingsState.mapGlobalSettings (always exampleGlobalSettings)
                    |> SettingsState.settings
                    |> Settings.globalSettings
                    |> Expect.equal GlobalSettings.default
        , test "does nothing if it is in the EditingBoard state" <|
            \() ->
                SettingsState.EditingBoard Settings.default BoardConfigsForm.empty
                    |> SettingsState.mapGlobalSettings (always exampleGlobalSettings)
                    |> SettingsState.settings
                    |> Settings.globalSettings
                    |> Expect.equal GlobalSettings.default
        , test "updates the current board if it is in the EditingGlobalSettings state" <|
            \() ->
                SettingsState.EditingGlobalSettings Settings.default BoardConfigsForm.empty
                    |> SettingsState.mapGlobalSettings (always exampleGlobalSettings)
                    |> SettingsState.settings
                    |> Settings.globalSettings
                    |> Expect.equal exampleGlobalSettings
        ]



-- HELPERS


exampleNewBoardConfig : NewBoardConfig
exampleNewBoardConfig =
    NewBoardConfig "foo" "emptyBoard"


noNameNewBoardConfig : NewBoardConfig
noNameNewBoardConfig =
    NewBoardConfig "" "emptyBoard"


exampleNewColumnConfig : NewColumnConfig
exampleNewColumnConfig =
    NewColumnConfig "a name" "a type"


unnamedNameNewBoardConfig : NewBoardConfig
unnamedNameNewBoardConfig =
    NewBoardConfig "Unnamed" "emptyBoard"


exampleBoardConfig : BoardConfig
exampleBoardConfig =
    BoardConfig.BoardConfig
        { columns = Columns.fromList [ Column.namedTag "foo" "bar" ]
        , filters = []
        , filterPolarity = Filter.Deny
        , filterScope = Filter.SubTasksOnly
        , showColumnTags = False
        , showFilteredTags = True
        , name = "Board Name"
        }


exampleBoardConfigMultiColumns : BoardConfig
exampleBoardConfigMultiColumns =
    BoardConfig.BoardConfig
        { columns =
            Columns.fromList
                [ Column.namedTag "named" "aTag"
                , Column.untagged "untagged"
                , Column.completed <| CompletedColumn.init "completed" 2 5
                ]
        , filters = []
        , filterPolarity = Filter.Deny
        , filterScope = Filter.SubTasksOnly
        , showColumnTags = False
        , showFilteredTags = True
        , name = "Board Name"
        }


exampleBoardConfigNoColumns : BoardConfig
exampleBoardConfigNoColumns =
    BoardConfig.BoardConfig
        { columns = Columns.empty
        , filters = []
        , filterPolarity = Filter.Deny
        , filterScope = Filter.SubTasksOnly
        , showColumnTags = False
        , showFilteredTags = True
        , name = "Board Name"
        }


exampleBoardConfigsForm : BoardConfigsForm.Form
exampleBoardConfigsForm =
    SafeZipper.fromList
        [ BoardConfig.fromNewBoardConfig DefaultColumnNames.default (NewBoardConfig "foo" "emptyBoard")
        , BoardConfig.fromNewBoardConfig DefaultColumnNames.default (NewBoardConfig "baz" "tagBoard")
        ]
        |> SafeZipper.atIndex 1
        |> BoardConfigsForm.init


exampleBoardConfigsFormEmpty : BoardConfigsForm.Form
exampleBoardConfigsFormEmpty =
    SafeZipper.fromList
        [ BoardConfig.fromNewBoardConfig DefaultColumnNames.default (NewBoardConfig "foo" "emptyBoard")
        , BoardConfig.fromNewBoardConfig DefaultColumnNames.default (NewBoardConfig "baz" "emptyBoard")
        ]
        |> SafeZipper.atIndex 1
        |> BoardConfigsForm.init


exampleGlobalSettings : GlobalSettings
exampleGlobalSettings =
    { taskCompletionFormat = GlobalSettings.ObsidianTasks
    , defaultColumnNames = DefaultColumnNames.default
    , ignoreFileNameDates = False
    }


newColumnConfig : SettingsState -> Maybe NewColumnConfig
newColumnConfig settingsState =
    case settingsState of
        SettingsState.AddingColumn ncc _ _ ->
            Just ncc

        _ ->
            Nothing


settingsFromBoardConfigs : List BoardConfig -> Settings
settingsFromBoardConfigs boardConfigs_ =
    Settings.default
        |> Settings.updateBoardConfigs (SafeZipper.fromList boardConfigs_)


settingsFromBoardConfigsWithIndex : Int -> List BoardConfig -> Settings
settingsFromBoardConfigsWithIndex index boardConfigs_ =
    Settings.default
        |> Settings.updateBoardConfigs
            (SafeZipper.atIndex index <| SafeZipper.fromList boardConfigs_)
