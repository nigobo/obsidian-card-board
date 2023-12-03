module BoardTests exposing (suite)

import Board
import BoardConfig
import Card
import CollapsedColumns
import Column
import DateBoardConfig exposing (DateBoardConfig)
import Expect
import Filter
import Helpers.BoardConfigHelpers as BoardConfigHelpers
import Helpers.BoardHelpers as BoardHelpers
import Helpers.DateTimeHelpers as DateTimeHelpers
import Helpers.FilterHelpers as FilterHelpers
import Helpers.TaskListHelpers as TaskListHelpers
import TagBoardConfig exposing (TagBoardConfig)
import TaskItem
import Test exposing (..)


suite : Test
suite =
    concat
        [ columnsDateBoard
        , columnsTagBoard
        ]


columnsDateBoard : Test
columnsDateBoard =
    describe "columns - dateboard"
        [ describe "filtering"
            [ test "can filter tasks to be from a given file" <|
                \() ->
                    TaskListHelpers.exampleDateBoardTaskList
                        |> Board.init
                            "d1"
                            (BoardConfig.DateBoardConfig
                                { exampleDateBoardConfig
                                    | filters =
                                        [ FilterHelpers.fileFilter "gg/xx/yy.md" ]
                                    , filterPolarity = Filter.Allow
                                }
                            )
                        |> Board.columns False DateTimeHelpers.todayDate
                        |> BoardHelpers.thingsInColumn "Undated"
                        |> List.map Card.taskItem
                        |> List.map TaskItem.title
                        |> Expect.equal
                            [ "an undated incomplete"
                            , "an undated incomplete with subtask"
                            , "incomplete with cTag"
                            , "incomplete with subtask with cTag"
                            , "untagged incomplete"
                            ]
            , test "can filter tasks to NOT be from a given file" <|
                \() ->
                    TaskListHelpers.exampleDateBoardTaskList
                        |> Board.init
                            "d1"
                            (BoardConfig.DateBoardConfig
                                { exampleDateBoardConfig
                                    | filters =
                                        [ FilterHelpers.fileFilter "gg/xx/yy.md"
                                        , FilterHelpers.fileFilter "x"
                                        , FilterHelpers.fileFilter "b"
                                        , FilterHelpers.fileFilter "c"
                                        , FilterHelpers.fileFilter "d"
                                        ]
                                    , filterPolarity = Filter.Deny
                                }
                            )
                        |> Board.columns False DateTimeHelpers.todayDate
                        |> BoardHelpers.thingsInColumn "Completed"
                        |> List.map Card.taskItem
                        |> List.map TaskItem.title
                        |> Expect.equal
                            [ "future complete"
                            , "yesterday complete"
                            , "invalid date complete"
                            ]
            , test "can filter tasks to be from a given path" <|
                \() ->
                    TaskListHelpers.taskListFromFile "aa/bb/c.ext"
                        |> Board.init
                            "d1"
                            (BoardConfig.DateBoardConfig
                                { exampleDateBoardConfig
                                    | filters = [ FilterHelpers.pathFilter "aa/bb" ]
                                    , filterPolarity = Filter.Allow
                                }
                            )
                        |> Board.columns False DateTimeHelpers.todayDate
                        |> BoardHelpers.thingsInColumn "Undated"
                        |> List.map Card.taskItem
                        |> List.map TaskItem.title
                        |> Expect.equal [ "c1" ]
            , test "can filter tasks to NOT be from a given path" <|
                \() ->
                    TaskListHelpers.taskListFromFile "aa/bb/c.ext"
                        |> Board.init
                            "d1"
                            (BoardConfig.DateBoardConfig
                                { exampleDateBoardConfig
                                    | filters = [ FilterHelpers.pathFilter "aa/bb" ]
                                    , filterPolarity = Filter.Deny
                                }
                            )
                        |> Board.columns False DateTimeHelpers.todayDate
                        |> BoardHelpers.thingsInColumn "Undated"
                        |> List.map Card.taskItem
                        |> List.map TaskItem.title
                        |> Expect.equal []
            , test "can filter tasks to have a given tag checking both top level and sub tasks" <|
                \() ->
                    TaskListHelpers.exampleDateBoardTaskList
                        |> Board.init
                            "d1"
                            (BoardConfig.DateBoardConfig
                                { exampleDateBoardConfig
                                    | filters = [ FilterHelpers.tagFilter "aTag" ]
                                    , filterPolarity = Filter.Allow
                                    , filterScope = Filter.Both
                                }
                            )
                        |> Board.columns False DateTimeHelpers.todayDate
                        |> BoardHelpers.thingsInColumn "Undated"
                        |> List.map Card.taskItem
                        |> List.map TaskItem.title
                        |> Expect.equal [ "invalid date incomplete", "invalid date incomplete with sub-task" ]
            , test "can filter tasks to have a given tag checking just top level tasks" <|
                \() ->
                    TaskListHelpers.exampleDateBoardTaskList
                        |> Board.init
                            "d1"
                            (BoardConfig.DateBoardConfig
                                { exampleDateBoardConfig
                                    | filters = [ FilterHelpers.tagFilter "aTag" ]
                                    , filterPolarity = Filter.Allow
                                    , filterScope = Filter.TopLevelOnly
                                }
                            )
                        |> Board.columns False DateTimeHelpers.todayDate
                        |> BoardHelpers.thingsInColumn "Undated"
                        |> List.map Card.taskItem
                        |> List.map TaskItem.title
                        |> Expect.equal [ "invalid date incomplete" ]
            , test "can filter tasks to have a given tag checking just sub-tasks" <|
                \() ->
                    TaskListHelpers.exampleDateBoardTaskList
                        |> Board.init
                            "d1"
                            (BoardConfig.DateBoardConfig
                                { exampleDateBoardConfig
                                    | filters = [ FilterHelpers.tagFilter "aTag" ]
                                    , filterPolarity = Filter.Allow
                                    , filterScope = Filter.SubTasksOnly
                                }
                            )
                        |> Board.columns False DateTimeHelpers.todayDate
                        |> BoardHelpers.thingsInColumn "Undated"
                        |> List.map Card.taskItem
                        |> List.map TaskItem.title
                        |> Expect.equal [ "invalid date incomplete with sub-task" ]
            , test "can filter tasks to NOT have a given tag checking both the top level task and its sub-tasks" <|
                \() ->
                    TaskListHelpers.exampleDateBoardTaskList
                        |> Board.init
                            "d1"
                            (BoardConfig.DateBoardConfig
                                { exampleDateBoardConfig
                                    | filters =
                                        [ FilterHelpers.tagFilter "aTag"
                                        , FilterHelpers.tagFilter "cTag"
                                        ]
                                    , filterPolarity = Filter.Deny
                                    , filterScope = Filter.Both
                                }
                            )
                        |> Board.columns False DateTimeHelpers.todayDate
                        |> BoardHelpers.thingsInColumn "Undated"
                        |> List.map Card.taskItem
                        |> List.map TaskItem.title
                        |> Expect.equal
                            [ "an undated incomplete"
                            , "an undated incomplete with subtask"
                            , "more undated incomplete"
                            , "untagged incomplete"
                            ]
            , test "can filter tasks to NOT have a given tag checking just the top level task" <|
                \() ->
                    TaskListHelpers.exampleDateBoardTaskList
                        |> Board.init
                            "d1"
                            (BoardConfig.DateBoardConfig
                                { exampleDateBoardConfig
                                    | filters =
                                        [ FilterHelpers.tagFilter "aTag"
                                        , FilterHelpers.tagFilter "cTag"
                                        ]
                                    , filterPolarity = Filter.Deny
                                    , filterScope = Filter.TopLevelOnly
                                }
                            )
                        |> Board.columns False DateTimeHelpers.todayDate
                        |> BoardHelpers.thingsInColumn "Undated"
                        |> List.map Card.taskItem
                        |> List.map TaskItem.title
                        |> Expect.equal
                            [ "an undated incomplete"
                            , "an undated incomplete with subtask"
                            , "incomplete with subtask with cTag"
                            , "invalid date incomplete with sub-task"
                            , "more undated incomplete"
                            , "untagged incomplete"
                            ]
            , test "can filter tasks to NOT have a given tag checking just the sub tasks" <|
                \() ->
                    TaskListHelpers.exampleDateBoardTaskList
                        |> Board.init
                            "d1"
                            (BoardConfig.DateBoardConfig
                                { exampleDateBoardConfig
                                    | filters =
                                        [ FilterHelpers.tagFilter "aTag"
                                        , FilterHelpers.tagFilter "cTag"
                                        ]
                                    , filterPolarity = Filter.Deny
                                    , filterScope = Filter.SubTasksOnly
                                }
                            )
                        |> Board.columns False DateTimeHelpers.todayDate
                        |> BoardHelpers.thingsInColumn "Undated"
                        |> List.map Card.taskItem
                        |> List.map TaskItem.title
                        |> Expect.equal
                            [ "an undated incomplete"
                            , "an undated incomplete with subtask"
                            , "incomplete with cTag"
                            , "invalid date incomplete"
                            , "more undated incomplete"
                            , "more undated incomplete with cTag"
                            , "untagged incomplete"
                            ]
            , test "filters tasks that are either in a file or path AND have one of the given tags" <|
                \() ->
                    TaskListHelpers.exampleDateBoardTaskList
                        |> Board.init
                            "d1"
                            (BoardConfig.DateBoardConfig
                                { exampleDateBoardConfig
                                    | filters =
                                        [ FilterHelpers.fileFilter "f"
                                        , FilterHelpers.pathFilter "gg"
                                        , FilterHelpers.tagFilter "aTag"
                                        , FilterHelpers.tagFilter "bTag"
                                        ]
                                    , filterPolarity = Filter.Allow
                                    , filterScope = Filter.Both
                                }
                            )
                        |> Board.columns False DateTimeHelpers.todayDate
                        |> BoardHelpers.thingsInColumn "Undated"
                        |> List.map Card.taskItem
                        |> List.map TaskItem.title
                        |> Expect.equal
                            [ "an undated incomplete"
                            , "an undated incomplete with subtask"
                            , "invalid date incomplete"
                            , "invalid date incomplete with sub-task"
                            ]
            , test "filters tasks that are NOT in the given files and paths AND DO NOT have one of the given tags" <|
                \() ->
                    TaskListHelpers.exampleDateBoardTaskList
                        |> Board.init
                            "d1"
                            (BoardConfig.DateBoardConfig
                                { exampleDateBoardConfig
                                    | filters =
                                        [ FilterHelpers.fileFilter "f"
                                        , FilterHelpers.pathFilter "gg"
                                        , FilterHelpers.tagFilter "aTag"
                                        , FilterHelpers.tagFilter "bTag"
                                        ]
                                    , filterPolarity = Filter.Deny
                                }
                            )
                        |> Board.columns False DateTimeHelpers.todayDate
                        |> BoardHelpers.thingsInColumn "Undated"
                        |> List.map Card.taskItem
                        |> List.map TaskItem.title
                        |> Expect.equal
                            [ "more undated incomplete with cTag" ]
            ]
        ]


columnsTagBoard : Test
columnsTagBoard =
    describe "columns - tagboard"
        [ describe "filtering"
            [ test "can filter tasks to be from a given file" <|
                \() ->
                    TaskListHelpers.exampleTagBoardTaskList
                        |> Board.init
                            "d1"
                            (BoardConfig.TagBoardConfig
                                { exampleTagBoardConfig
                                    | filters = [ FilterHelpers.fileFilter "a" ]
                                    , filterPolarity = Filter.Allow
                                }
                            )
                        |> Board.columns False DateTimeHelpers.todayDate
                        |> BoardHelpers.thingsInColumn "Others"
                        |> List.map Card.taskItem
                        |> List.map TaskItem.title
                        |> Expect.equal
                            [ "a.tag1"
                            , "a.tag2"
                            , "a.tag3"
                            ]
            , test "can filter tasks to NOT be from a given file" <|
                \() ->
                    TaskListHelpers.exampleTagBoardTaskList
                        |> Board.init
                            "d1"
                            (BoardConfig.TagBoardConfig
                                { exampleTagBoardConfig
                                    | filters = [ FilterHelpers.fileFilter "a" ]
                                    , filterPolarity = Filter.Deny
                                }
                            )
                        |> Board.columns False DateTimeHelpers.todayDate
                        |> BoardHelpers.thingsInColumn "Others"
                        |> List.map Card.taskItem
                        |> List.map TaskItem.title
                        |> Expect.equal
                            [ "b.tag1"
                            , "b.tag2"
                            , "b.tag3"
                            , "c.tag1"
                            , "c.tag2"
                            , "c.tag3"
                            ]
            , test "can filter tasks to be from a given path" <|
                \() ->
                    TaskListHelpers.exampleTagBoardTaskList
                        |> Board.init
                            "d1"
                            (BoardConfig.TagBoardConfig
                                { exampleTagBoardConfig
                                    | filters = [ FilterHelpers.pathFilter "aa" ]
                                    , filterPolarity = Filter.Allow
                                }
                            )
                        |> Board.columns False DateTimeHelpers.todayDate
                        |> BoardHelpers.thingsInColumn "Others"
                        |> List.map Card.taskItem
                        |> List.map TaskItem.title
                        |> Expect.equal
                            [ "c.tag1"
                            , "c.tag2"
                            , "c.tag3"
                            ]
            , test "can filter tasks to NOT be from a given path" <|
                \() ->
                    TaskListHelpers.exampleTagBoardTaskList
                        |> Board.init
                            "d1"
                            (BoardConfig.TagBoardConfig
                                { exampleTagBoardConfig
                                    | filters = [ FilterHelpers.pathFilter "aa" ]
                                    , filterPolarity = Filter.Deny
                                }
                            )
                        |> Board.columns False DateTimeHelpers.todayDate
                        |> BoardHelpers.thingsInColumn "Others"
                        |> List.map Card.taskItem
                        |> List.map TaskItem.title
                        |> Expect.equal
                            [ "a.tag1"
                            , "a.tag2"
                            , "a.tag3"
                            , "b.tag1"
                            , "b.tag2"
                            , "b.tag3"
                            ]
            , test "can filter tasks to have a given tag" <|
                \() ->
                    TaskListHelpers.exampleTagBoardTaskList
                        |> Board.init
                            "d1"
                            (BoardConfig.TagBoardConfig
                                { exampleTagBoardConfig
                                    | filters = [ FilterHelpers.tagFilter "tag1" ]
                                    , filterPolarity = Filter.Allow
                                    , filterScope = Filter.Both
                                }
                            )
                        |> Board.columns False DateTimeHelpers.todayDate
                        |> BoardHelpers.thingsInColumn "Others"
                        |> List.map Card.taskItem
                        |> List.map TaskItem.title
                        |> Expect.equal
                            [ "a.tag1"
                            , "b.tag1"
                            , "c.tag1"
                            ]
            , test "can filter tasks to NOT have a given tag" <|
                \() ->
                    TaskListHelpers.exampleTagBoardTaskList
                        |> Board.init
                            "d1"
                            (BoardConfig.TagBoardConfig
                                { exampleTagBoardConfig
                                    | filters = [ FilterHelpers.tagFilter "tag1" ]
                                    , filterPolarity = Filter.Deny
                                    , filterScope = Filter.Both
                                }
                            )
                        |> Board.columns False DateTimeHelpers.todayDate
                        |> BoardHelpers.thingsInColumn "Others"
                        |> List.map Card.taskItem
                        |> List.map TaskItem.title
                        |> Expect.equal
                            [ "a.tag2"
                            , "a.tag3"
                            , "b.tag2"
                            , "b.tag3"
                            , "c.tag2"
                            , "c.tag3"
                            ]
            , test "filters tasks that are either in a file or path AND have one of the given tags" <|
                \() ->
                    TaskListHelpers.exampleTagBoardTaskList
                        |> Board.init
                            "d1"
                            (BoardConfig.TagBoardConfig
                                { exampleTagBoardConfig
                                    | filters =
                                        [ FilterHelpers.fileFilter "a"
                                        , FilterHelpers.pathFilter "aa"
                                        , FilterHelpers.tagFilter "tag1"
                                        , FilterHelpers.tagFilter "tag2"
                                        ]
                                    , filterPolarity = Filter.Allow
                                    , filterScope = Filter.Both
                                }
                            )
                        |> Board.columns False DateTimeHelpers.todayDate
                        |> BoardHelpers.thingsInColumn "Others"
                        |> List.map Card.taskItem
                        |> List.map TaskItem.title
                        |> Expect.equal
                            [ "a.tag1"
                            , "a.tag2"
                            , "c.tag1"
                            , "c.tag2"
                            ]
            , test "filters tasks that are NOT in any of the given file or path AND DO NOT have one of the given tags" <|
                \() ->
                    TaskListHelpers.exampleTagBoardTaskList
                        |> Board.init
                            "d1"
                            (BoardConfig.TagBoardConfig
                                { exampleTagBoardConfig
                                    | filters =
                                        [ FilterHelpers.fileFilter "a"
                                        , FilterHelpers.pathFilter "aa"
                                        , FilterHelpers.tagFilter "tag1"
                                        , FilterHelpers.tagFilter "tag2"
                                        ]
                                    , filterPolarity = Filter.Deny
                                    , filterScope = Filter.Both
                                }
                            )
                        |> Board.columns False DateTimeHelpers.todayDate
                        |> BoardHelpers.thingsInColumn "Others"
                        |> List.map Card.taskItem
                        |> List.map TaskItem.title
                        |> Expect.equal [ "b.tag3" ]
            ]
        ]



-- HELPERS


exampleDateBoardConfig : DateBoardConfig
exampleDateBoardConfig =
    BoardConfigHelpers.exampleDateBoardConfig


exampleTagBoardConfig : TagBoardConfig
exampleTagBoardConfig =
    BoardConfigHelpers.exampleTagBoardConfig
