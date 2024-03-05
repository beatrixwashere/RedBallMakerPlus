# v.1.1.1
- fixed a bug where pressing apply in the edit menu didnt remove the polygon points
- fixed a bug where deleting a layer would keep its blocks in the list, which would crash on selection
- fixed a bug where the checkpoints/flags displayed in rbmp didn't line up with the actual level
- use ctrl+shift+e to copy the export txt to your clipboard

# v.1.1.0
- block list is now layered such that the bottom is in front
- adding blocks puts them at the bottom of the list
- pressing f with a block selected will move the camera to that block
- right click moves the camera instead of middle click
- use ctrl+e to export, ctrl+s to save, ctrl+o to load, and ctrl+i to import
- hold shift when reordering a block to bring it to the top/bottom
- fixed an issue with floating point imprecision when exporting/saving
- the level now autosaves when closing the application, and loads when opening
- importing levels from txt files is now supported
- note #1: level imports only support blocks that are implemented in rbmp
- note #2: level import strings must have no spaces or newlines
- level exports are no longer formatted
- use ctrl+z to undo the most recent change
- redos will be implemented in v.1.1.1
- use x to toggle gridsnap, placing blocks at the nearest multiple of 10
- fixed a crash that occurred when pressing apply without a block selected
- polygons can now be edited by clicking and dragging their vertices
- to use this feature, click on the edit button next to points
- settings window now doesn't require you to click out of the window to rebind
- use c to toggle block name labels
- frames per second is now shown in the info row
- block visibility can now be toggled
- ui list nodes are shorter
- changed the move up and down in list icons
- added layers (THANK FUCKING GOD ITS OVER THAT TOOK SO LONG)

---

# v.1.0.1
- update the listobj's name when applying changes
- make the polygon scroll container fit the whole window
- add discord links to the readme

---

# v.1.0.0
- rbmp is ready!! :D
- this release includes basic functionality for making levels
- please make suggestions and report bugs to help improve the tool <3
