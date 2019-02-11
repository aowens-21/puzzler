#lang puzzler

START_MAP
P#######
##B##G##
####B##T
########
##B#####
###GB###
##B####B
########
END_MAP

draw:
  "P" -> "player.png"
  "B" -> "rect"
  "T" -> "coop.jpg"
  "G" -> "guard.png"

action:
  "P": "up" -> (0, 1)
  "P": "down" -> (0, -1)
  "P": "left" -> (-1, 0)
  "P": "right" -> (1, 0)

interactions:
  "P" push "B"
  "P" grab "T"
  "B" stop "G"

lose:
  "G" straight_path_to "P"

win:
  "T" count_items 0