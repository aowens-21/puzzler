#lang puzzler

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
  "P" onexit "W"
  "P" stop "W"
  "W" stop "W"
  "P" grab "T"

win:
  "P" == "T"