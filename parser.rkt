#lang brag

puzzler-program: (puzzler-line)+

@puzzler-line: puzzler-map | draw-block | action-block | win-block | lose-block | interactions-block | events-block | puzzler-goal-map | /NEWLINE-TOKEN

puzzler-map: /START-MAP-TOKEN /NEWLINE-TOKEN (map-row)+ /END-MAP-TOKEN

map-row: (MAP-CHAR-TOKEN)+ /NEWLINE-TOKEN

puzzler-goal-map: /START-GOAL-MAP-TOKEN /NEWLINE-TOKEN (goal-map-row)+ /END-GOAL-MAP-TOKEN

goal-map-row: (MAP-CHAR-TOKEN)+ /NEWLINE-TOKEN

draw-block: /DRAW-TOKEN /NEWLINE-TOKEN (draw-rule)+

draw-rule: ID /RULE-RESULT-TOKEN STRING-TOKEN /(NEWLINE-TOKEN)?

action-block: /ACTION-TOKEN /NEWLINE-TOKEN (action-rule)+

action-rule: ID /":" STRING-TOKEN /RULE-RESULT-TOKEN /"(" NUM-TOKEN /"," NUM-TOKEN /")" /(NEWLINE-TOKEN)?

interactions-block: /INTERACTIONS-TOKEN /NEWLINE-TOKEN (interaction-rule)+

interaction-rule: (ID PUSH-TOKEN ID | ID STOP-TOKEN ID | ID GRAB-TOKEN ID) /(NEWLINE-TOKEN)?

events-block: /EVENTS-TOKEN /NEWLINE-TOKEN (event-rule)+

event-rule: (ID ONEXIT-TOKEN ID) /(NEWLINE-TOKEN)?

win-block: /WIN-TOKEN /NEWLINE-TOKEN (win-rule)+

win-rule: ID COUNT-ITEMS-TOKEN NUM-TOKEN | ID STRAIGHT-PATH-TO-TOKEN ID

lose-block: /LOSE-TOKEN /NEWLINE-TOKEN (lose-rule)+

lose-rule: ID COUNT-ITEMS-TOKEN NUM-TOKEN | ID STRAIGHT-PATH-TO-TOKEN ID