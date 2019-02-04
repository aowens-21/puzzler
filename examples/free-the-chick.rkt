#lang puzzler

START_MAP
BBBBBBBB
BP#####B
B######B
B####BBB
B###B##B
B###B#CB
B###B##B
BBBBBBBB
END_MAP

-- Takes care of where to draw things
draw:
  "P" -> "player.png"
  "C" -> "chick.jpg"
  "B" -> "rect"

-- Takes care of how to respond to key inputs
action:
  "P": "up" -> (0, 1)
  "P": "down" -> (0, -1)
  "P": "left" -> (-1, 0)
  "P": "right" -> (1, 0)

-- Takes care of when player is trying to move into block position, will push
interactions:
  "P" push "B"
  "B" stop "B"
  "P" grab "C"

-- Takes care of win conditions - maybe be more explicit with positions
win:
  "C" count_items 0