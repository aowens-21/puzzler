#lang puzzler

START_MAP
P#####
###W##
#WWW#W
######
T##W#T
W#TWWW
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

events:
  "P" onexit "W"

win:
  "T" count_items 0