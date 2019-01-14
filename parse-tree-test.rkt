#lang br
(require puzzler/tokenizer puzzler/parser brag/support)

(parse-to-datum (apply-tokenizer-maker make-tokenizer
#<<TEST
-- This takes care of map size, places
START_MAP
######
##B###
#B#BB#
#B#CB#
#BBBB#
######
END_MAP

-- Takes care of where to draw things
draw:
  "P" -> "player.png"
  "C" -> "chick.png"
  "B" -> "wall.png"
  "W" -> "wall.png"

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
  "B" stop "W"
  "P" stop "W"
  "B" stop "W"

-- Takes care of win conditions - maybe be more explicit with positions
win:
  "P" == "C"
TEST
))

