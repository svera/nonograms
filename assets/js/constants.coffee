# We use this file both at server and the client
root = global ? window

# Constants that identifies the mouse buttons
# 1 is for the main button (left button for right handed)
# 3 is for the secondary button (right button for right handed)
root.BUTTON_NOT_PRESSED = 0
root.MAIN_BUTTON        = 1
root.SECONDARY_BUTTON   = 3

# Constants for the values that a nonogram array can have
root.EMPTY_CELL  = '-1'
root.MARKED_CELL = '-2'

root.EMPTY_CELL_COLOR 		= 'fff'
root.HIGHLIGHTED_CELL_COLOR = '0f0'
