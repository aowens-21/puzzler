#lang br
(require puzzler/tokenizer puzzler/parser brag/support)

(parse-to-datum (apply-tokenizer-maker make-tokenizer
#<<TEST
START_MAP
P#####
######
######
######
#####T
######
END_MAP

draw:
  "P" -> "player.png"
  "W" -> "rect"
  "T" -> "coop.jpg"

action:
  "P": "up" -> (0, 1)
  "P": "down" -> (0, -1)
  "P": "left" -> (-1, 0)
  "P": "right" -> (1, 0)

interactions:
  "P" stop "W"
  "W" stop "W"
  "P" grab "T"

win:
  "T" count_items 0
TEST
))

