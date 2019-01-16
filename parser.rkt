#lang brag

puzzler-program: (puzzler-line)+

@puzzler-line: puzzler-map | draw-block | action-block | win-block | interactions-block | /NEWLINE-TOKEN

puzzler-map: /START-MAP-TOKEN /NEWLINE-TOKEN (map-row)+ /END-MAP-TOKEN

map-row: (MAP-CHAR-TOKEN)+ /NEWLINE-TOKEN

draw-block: /DRAW-TOKEN /NEWLINE-TOKEN (draw-rule)+

draw-rule: ID /RULE-RESULT-TOKEN STRING-TOKEN /(NEWLINE-TOKEN)?

action-block: /ACTION-TOKEN /NEWLINE-TOKEN (action-rule)+

action-rule: ID /":" STRING-TOKEN /RULE-RESULT-TOKEN /"(" NUM-TOKEN /"," NUM-TOKEN /")" /(NEWLINE-TOKEN)?

interactions-block: /INTERACTIONS-TOKEN /NEWLINE-TOKEN (interaction-rule)+

interaction-rule: (ID PUSH-TOKEN ID | ID STOP-TOKEN ID | ID GRAB-TOKEN ID | ID ONEXIT-TOKEN ID) /(NEWLINE-TOKEN)?

win-block: /WIN-TOKEN /NEWLINE-TOKEN (win-rule)+

win-rule: ID EQUALS-TOKEN ID | ID WIN-COUNT-TOKEN NUM-TOKEN