module CardTests exposing (suite)

import Card exposing (Highlight(..))
import DataviewTaskCompletion
import Date exposing (Date)
import Expect
import Helpers.TaskHelpers as TaskHelpers
import Helpers.TaskItemHelpers as TaskItemHelpers
import Parser
import TagList
import TaskItem exposing (TaskItem)
import Test exposing (..)
import Time
import TimeWithZone


suite : Test
suite =
    concat
        [ allTags
        , descendantTasks
        , displayTags
        , editButtonId
        , filePath
        , fromTaskItem
        , highlight
        , id
        , markdownWithIds
        , notesId
        , tagsId
        , taskItemId
        , title
        ]


allTags : Test
allTags =
    describe "allTags"
        [ test "returns an empty TagList if the TaskItem has no tags" <|
            \() ->
                taskItem
                    |> Maybe.map (Card.fromTaskItem "a_prefix" [])
                    |> Maybe.map Card.allTags
                    |> Expect.equal (Just TagList.empty)
        , test "returns the Tags from the TaskItem" <|
            \() ->
                taskItemWithTags
                    |> Maybe.map (Card.fromTaskItem "a_prefix" [])
                    |> Maybe.map Card.allTags
                    |> Maybe.map TagList.toStrings
                    |> Expect.equal (Just [ "arg", "bar", "baz/boo" ])
        , test "does not remove any tags even if the match the remove list" <|
            \() ->
                taskItemWithTags
                    |> Maybe.map (Card.fromTaskItem "a_prefix" [ "bar" ])
                    |> Maybe.map Card.allTags
                    |> Maybe.map TagList.toStrings
                    |> Expect.equal (Just [ "arg", "bar", "baz/boo" ])
        ]


descendantTasks : Test
descendantTasks =
    describe "descendantTasks"
        [ test "returns an empty list if there are no descendantTasks" <|
            \() ->
                taskItem
                    |> Maybe.map (Card.fromTaskItem "" [])
                    |> Maybe.map Card.descendantTasks
                    |> Expect.equal (Just [])
        , test "returns a list of the descendant tasks with the card idPrefix" <|
            \() ->
                """- [ ] foo

  - [ ] bar"""
                    |> Parser.run TaskItemHelpers.basicParser
                    |> Result.toMaybe
                    |> Maybe.map (Card.fromTaskItem "a_prefix" [])
                    |> Maybe.map Card.descendantTasks
                    |> Maybe.map (List.map <| Tuple.mapSecond TaskItem.title)
                    |> Expect.equal (Just [ ( "a_prefix:2166136261:3", "bar" ) ])
        ]


displayTags : Test
displayTags =
    describe "displayTags"
        [ test "returns an empty TagList if the TaskItem has no tags" <|
            \() ->
                taskItem
                    |> Maybe.map (Card.fromTaskItem "a_prefix" [])
                    |> Maybe.map Card.displayTags
                    |> Expect.equal (Just TagList.empty)
        , test "returns the Tags from the TaskItem" <|
            \() ->
                taskItemWithTags
                    |> Maybe.map (Card.fromTaskItem "a_prefix" [])
                    |> Maybe.map Card.displayTags
                    |> Maybe.map TagList.toStrings
                    |> Expect.equal (Just [ "arg", "bar", "baz/boo" ])
        , test "removes any tags matching the remove list" <|
            \() ->
                taskItemWithTags
                    |> Maybe.map (Card.fromTaskItem "a_prefix" [ "bar" ])
                    |> Maybe.map Card.displayTags
                    |> Maybe.map TagList.toStrings
                    |> Expect.equal (Just [ "arg", "baz/boo" ])
        ]


editButtonId : Test
editButtonId =
    describe "editButtonId"
        [ test "adds :editButton on to the end of the Card.id" <|
            \() ->
                taskItem
                    |> Maybe.map (Card.fromTaskItem "prefix" [])
                    |> Maybe.map Card.editButtonId
                    |> Expect.equal (Just <| "prefix:" ++ TaskHelpers.taskId "taskItemPath" 1 ++ ":editButton")
        ]


filePath : Test
filePath =
    describe "filePath"
        [ test "returns the filePath of the taskItem" <|
            \() ->
                taskItem
                    |> Maybe.map (Card.fromTaskItem "" [])
                    |> Maybe.map Card.filePath
                    |> Expect.equal (Just <| "taskItemPath")
        ]


fromTaskItem : Test
fromTaskItem =
    describe "fromTaskItem"
        [ test "prefixes the Card.id with the given prefix" <|
            \() ->
                taskItem
                    |> Maybe.map (Card.fromTaskItem "prefixed" [])
                    |> Maybe.map Card.id
                    |> Expect.equal (Just <| "prefixed:" ++ TaskHelpers.taskId "taskItemPath" 1)
        ]


highlight : Test
highlight =
    describe "highlight"
        [ test "returns HighlightNone for a task with no due date" <|
            \() ->
                "- [ ] foo"
                    |> Parser.run TaskItemHelpers.basicParser
                    |> Result.map (Card.fromTaskItem "" [])
                    |> Result.map (Card.highlight janFirstTwentyTwenty)
                    |> Expect.equal (Ok HighlightNone)
        , test "returns HighlightImportant for a task that is due today" <|
            \() ->
                "- [ ] foo @due(2020-01-01)"
                    |> Parser.run TaskItemHelpers.basicParser
                    |> Result.map (Card.fromTaskItem "" [])
                    |> Result.map (Card.highlight janFirstTwentyTwenty)
                    |> Expect.equal (Ok HighlightImportant)
        , test "returns HighlightNone for a completed task that is due today" <|
            \() ->
                "- [x] foo @due(2020-01-01)"
                    |> Parser.run TaskItemHelpers.basicParser
                    |> Result.map (Card.fromTaskItem "" [])
                    |> Result.map (Card.highlight janFirstTwentyTwenty)
                    |> Expect.equal (Ok HighlightNone)
        , test "returns HighlightCritical for a task that is overdue" <|
            \() ->
                "- [ ] foo @due(2019-01-01)"
                    |> Parser.run TaskItemHelpers.basicParser
                    |> Result.map (Card.fromTaskItem "" [])
                    |> Result.map (Card.highlight janFirstTwentyTwenty)
                    |> Expect.equal (Ok HighlightCritical)
        , test "returns HighlightNone for a completed task that is overdue" <|
            \() ->
                "- [x] foo @due(2019-01-01)"
                    |> Parser.run TaskItemHelpers.basicParser
                    |> Result.map (Card.fromTaskItem "" [])
                    |> Result.map (Card.highlight janFirstTwentyTwenty)
                    |> Expect.equal (Ok HighlightNone)
        , test "returns HighlightGood for a task that is due in the future" <|
            \() ->
                "- [ ] foo @due(2020-01-02)"
                    |> Parser.run TaskItemHelpers.basicParser
                    |> Result.map (Card.fromTaskItem "" [])
                    |> Result.map (Card.highlight janFirstTwentyTwenty)
                    |> Expect.equal (Ok HighlightGood)
        , test "returns HighlightNone for a completed task that is due in the future" <|
            \() ->
                "- [x] foo @due(2020-01-02)"
                    |> Parser.run TaskItemHelpers.basicParser
                    |> Result.map (Card.fromTaskItem "" [])
                    |> Result.map (Card.highlight janFirstTwentyTwenty)
                    |> Expect.equal (Ok HighlightNone)
        ]


id : Test
id =
    describe "id"
        [ test "returns the id of the taskItem with the card prefix" <|
            \() ->
                taskItem
                    |> Maybe.map (Card.fromTaskItem "the_prefix" [])
                    |> Maybe.map Card.id
                    |> Expect.equal (Just "the_prefix:1754873316:1")
        ]


markdownWithIds : Test
markdownWithIds =
    describe "markdownWithIds"
        [ test "extracts the taskItem title, descendant task titles, tags, and notes with their respective ids" <|
            \() ->
                """- [ ] foo #tag1
 some note
  - [ ] bar #tag2
 more notes #tag3
  - [x] baz
  """
                    |> Parser.run (TaskItem.parser DataviewTaskCompletion.NoCompletion "file" Nothing TagList.empty 0)
                    |> Result.toMaybe
                    |> Maybe.map (Card.fromTaskItem "prefix" [])
                    |> Maybe.map Card.markdownWithIds
                    |> Expect.equal
                        (Just
                            [ { id = "prefix:" ++ TaskHelpers.taskId "file" 1 ++ ":tags", markdown = "#tag1" }
                            , { id = "prefix:" ++ TaskHelpers.taskId "file" 1 ++ ":notes", markdown = "some note\nmore notes #tag3" }
                            , { id = "prefix:" ++ TaskHelpers.taskId "file" 3, markdown = "bar #tag2" }
                            , { id = "prefix:" ++ TaskHelpers.taskId "file" 5, markdown = "~~baz~~" }
                            , { id = "prefix:" ++ TaskHelpers.taskId "file" 1, markdown = "foo" }
                            ]
                        )
        , test "extracts the taskItem title and descendant task titles with their respective ids (if there are no notes)" <|
            \() ->
                """- [x] foo
  - [ ] bar
  """
                    |> Parser.run (TaskItem.parser DataviewTaskCompletion.NoCompletion "file" Nothing TagList.empty 0)
                    |> Result.toMaybe
                    |> Maybe.map (Card.fromTaskItem "prefix" [])
                    |> Maybe.map Card.markdownWithIds
                    |> Expect.equal
                        (Just
                            [ { id = "prefix:" ++ TaskHelpers.taskId "file" 2, markdown = "bar" }
                            , { id = "prefix:" ++ TaskHelpers.taskId "file" 1, markdown = "~~foo~~" }
                            ]
                        )
        ]


notesId : Test
notesId =
    describe "notesId"
        [ test "adds :notes on to the end of the Card.id" <|
            \() ->
                taskItem
                    |> Maybe.map (Card.fromTaskItem "a_prefix" [])
                    |> Maybe.map Card.notesId
                    |> Expect.equal (Just <| "a_prefix:" ++ TaskHelpers.taskId "taskItemPath" 1 ++ ":notes")
        ]


tagsId : Test
tagsId =
    describe "tagsId"
        [ test "adds :tags on to the end of the Card.id" <|
            \() ->
                taskItem
                    |> Maybe.map (Card.fromTaskItem "a_prefix" [])
                    |> Maybe.map Card.tagsId
                    |> Expect.equal (Just <| "a_prefix:" ++ TaskHelpers.taskId "taskItemPath" 1 ++ ":tags")
        ]


taskItemId : Test
taskItemId =
    describe "taskItemId"
        [ test "taskItemId is just the id of the taskItem (without the idPrefix)" <|
            \() ->
                taskItem
                    |> Maybe.map (Card.fromTaskItem "foo" [])
                    |> Maybe.map Card.taskItemId
                    |> Expect.equal (Just (TaskHelpers.taskId "taskItemPath" 1))
        ]


title : Test
title =
    describe "title"
        [ test "returns the title of the TaskItem" <|
            \() ->
                taskItem
                    |> Maybe.map (Card.fromTaskItem "" [])
                    |> Maybe.map Card.title
                    |> Expect.equal (Just "foo")
        ]



-- HELPERS


janFirstTwentyTwenty : Date
janFirstTwentyTwenty =
    { time = Time.millisToPosix 1577836800000, zone = Time.utc }
        |> TimeWithZone.toDate


taskItem : Maybe TaskItem
taskItem =
    "- [ ] foo"
        |> Parser.run (TaskItem.parser DataviewTaskCompletion.NoCompletion "taskItemPath" Nothing TagList.empty 0)
        |> Result.toMaybe


taskItemWithTags : Maybe TaskItem
taskItemWithTags =
    "- [ ] foo #bar #baz/boo #arg"
        |> Parser.run (TaskItem.parser DataviewTaskCompletion.NoCompletion "taskItemPath" Nothing TagList.empty 0)
        |> Result.toMaybe
