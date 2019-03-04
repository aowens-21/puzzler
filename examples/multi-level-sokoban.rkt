#lang puzzler

START_MAP
P#####
######
##BBB#
######
######
######

####P#
##B###
######
######
######
######
END_MAP

START_GOAL_MAP
######
######
######
##B###
#B####
B#####

######
######
######
######
######
###B##
END_GOAL_MAP

draw:
  "P" -> "player.png"
  "B" -> "rect"

action:
  "P": "up" -> (0, 1)
  "P": "down" -> (0, -1)
  "P": "left" -> (-1, 0)
  "P": "right" -> (1, 0)

interactions:
  "P" push "B"
  "B" stop "B"