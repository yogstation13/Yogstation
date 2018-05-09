# Differences with /TG/Station

The best practice to have while coding is to keep everything modularized, or the most possible. Sometimes it's not possible and you're required to put a "hook" proc call in a TG file. This file is intended to have a list of those hooks, so their locations and purposes can be easily found.

### PRs that includes a hook addition to a TG file and fail to update this list will not be merged.

## List of edits

### Example change
ExampleProc() in /repo/ExampleTGFile.dm
Example change description
Example icon change

### Various Yogstation sprites by Partheo
Many "icon" variables have been changed from "icon = 'icons/x/y/z'" to "icon = 'yogstation/icons/x/y/z'"

### Mirrored and included Yogstation files
These files have been unencluded from Yogstation.dme, and mirrored into the appropriate directiory under the yogstation foler.
code/game/objects/items/stacks/rods.dm
code/game/objects/items/stacks/stack.dm
code/game/objects/items/stacks/sheets/glass.dm
code/game/objects/items/stacks/sheets/sheet_types.dm