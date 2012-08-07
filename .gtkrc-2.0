binding "gtk-binding-tree-view" {
    bind "j"        { "move-cursor" (display-lines, 1) }
    bind "k"        { "move-cursor" (display-lines, -1) }
    bind "h"        { "expand-collapse-cursor-row" (1,0,0) }
    bind "l"        { "expand-collapse-cursor-row" (1,1,0) }
    bind "o"        { "move-cursor" (pages, 1) }
    bind "u"        { "move-cursor" (pages, -1) }
    bind "g"        { "move-cursor" (buffer-ends, -1) }
    bind "y"        { "move-cursor" (buffer-ends, 1) }
    bind "p"        { "select-cursor-parent" () }
    bind "Left"     { "expand-collapse-cursor-row" (0,0,0) }
    bind "Right"    { "expand-collapse-cursor-row" (0,1,0) }
    bind "semicolon" { "expand-collapse-cursor-row" (0,1,1) }
    bind "slash"    { "start-interactive-search" () }
}
class "GtkTreeView" binding "gtk-binding-tree-view"