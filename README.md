# Obsidian CardBoard Plugin

A plugin for the (most wonderful) [Obsidian](https://obsidian.md/) which collates
tasks from all your notes and displays them on a Kanban-style board.

![date based board screenshot](/images/dateBoard.png?raw=true)

## Installation
I've not yet submitted this as an official plugin, so you will have to use the
v.handy [obsidian42 BRAT plugin](https://github.com/TfTHacker/obsidian42-brat) to install it, or manually install from the
[releases](https://github.com/roovo/obsidian-card-board/releases/) page, or
you can try a self-build - see the [contributing doc](CONTRIBUTING.md)).

## Use
When installed, use the icon in the app ribbon to launch.

![app ribbon icon](/images/ribbonIcon.png?raw=true)

You should get a dialog asking you to add a new board.  There are 2 types of board:

- **Date based**: looks like the main screenshot above
- **Tag based**: uses tags to define the columns (you need to include tags on
  your tasks for this to work)

Name and configure your board and you are good to go.

## Cards
Any task in your vault can appear as a card in a column on a board.  In order to
do this, it must:

- Be in a markdown file
- Not be indented.
- Have the format: `- [ ] Task title`.

What appears on the card depends on what your task looks like:

- Anything that is indented under a task will appear in the body of the task
- Indented tasks will appear as subtasks (all subtasks are grouped together)
- Indented text will appear as notes
- Tags on the line of the task (or any subtasks) will appear at the top of the card
- Any due date will appear at the bottom of the card.

So, if you had the following in one of your markdown files:

```
- [ ] run erands @due(2021-10-30)
  - [x] do shopping #town
  - [ ] wash car #home/outside
  - [ ] cook dinner #home/kitchen

  perhaps I should look up some [[example_tasks/recipes|recipes]] first

  - [ ] do something with a long title that will truncate when displayed
  - [ ] go to bed


```

It will look something like this on a card on your board:

![example card](/images/card.png?raw=true)

#### Marking a task as complete
If you mark an item as complete on the board it will be marked as completed in the markdown
(and vice-versa).  If you mark as complete on the board, a completion timestamp is appended
to the task:

```
- [x] Task title @completed(2021-10-30T13:57:48)
```

If you have subtasks and the parent task is tagged as an _autocomplete_ task then the main
task will be marked as complete when you tick off the final subtask:

```
- [ ] Task title @autocomplete(true)
  - [ ] Do this first
  - [ ] Do this next
  - [ ] Finally do this and you are done
```


### Deleting a task
You can delete a task using the trash icon on the card.  This will not actually delete
the task from your vault, it simply surrounds it with markdown `<del>` tags:

```
<del>- [x] Task title</del>
```

### Editing tasks (and hover preview)
Click on the edit icon to open the file containing the task.  Cmd (or Ctrl on windows)
hover over the icon for the normal Obsidian hover preview.

## Date boards
You will get the best out of these if you are using the (core) Daily Notes plugin as any
tasks you place on a daily note will be assigned to the day of the note.

You can also assign a date to any task using the format:

```
- [ ] My task due(2021-10-31)
```

## Tag boards
If you give your tasks tags, you can use these to set up a tag-board.  So if you
have the tags `#project1/backlog`, `#project1/triaged`, `project1/blocked`, `#project1/doing`,
you can define a board that shows tasks tagged with these in separate columns:

![tag board settingx](/images/tagBoardSettings.png?raw=true)


## Settings
The plugin settings are (only) accessible from the plugin view (via the settings icon
above the board to the left of the tabs).  With these, you can

- Create new boards (using the + icon next to _BOARDS_)
- Configure your boards
- Delete any boards you no longer need

## Limitations
- Uses the settings from the Daily Notes plugin, NOT periodic notes (will fix soon)
- Might not work that great on large vaults (as it parses all markdown files at startup)
- Might not be great on mobile (see previous, plus I haven't made the interface mobile
  friendly - yet)

## Alternatives
If the way that this works doesn't work for you, there are plenty of other plugins you
can use for task management in Obsidian.  See the list on the wonderful
[roundup site](https://www.obsidianroundup.org/plugins/).

## Contributing
Not worked out how/if this will work yet as it is early days.  There is
a [contributing doc](CONTRIBUTING.md) that at the moment lets you know
how to build the project if you want to have a play.

Feel free to add any bugs/suggestions/feature requests as
[github issues](https://github.com/roovo/obsidian-card-board/issues).

