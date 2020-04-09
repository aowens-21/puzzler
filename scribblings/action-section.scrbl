#lang scribble/manual
@(require (for-label
           racket
           racket/gui/base))

@title{Actions}

The Puzzler language supports basic keyboard input via the @italic{action section}. @bold{Currently the only supported type of input is moving entities around the game grid.}

@section{Action Rules}

The @italic{action section} starts off similar to the draw section, with the only difference being how you define @italic{action rule}s:

@verbatim{
 action:
 <action_rule>
 ...
}

@italic{Action rule}s consist of 3 parts: an entity, the key that invokes the action, a coordinate pair representing the change in position of the specified entity. This is easiest
to visualize with an example, here's one from our @seclink["sokoban"]{Sokoban game}:

@verbatim{
 action:
 "P": "up" -> (0, 1)
 ...
}

We can break this rule down piece by piece, first noting that we are applying this action to the "P" entity (in our example this is the player). The next piece of information is the key to press
to trigger the action, which we specify with the word "up" (key names are the ones returned from @racket[get-key-code] in racket/gui/base. The final part of our rule is a coordinate pair representing
the change in x and change in y (dx,dy) that we want our "P" entity to move by when we press "up". For this we have (0, 1), which means move 0 in the x-direction and 1 in the y-direction,
and in our case this works well because we want our "P" to move up by 1 grid square. The rest of the action section should make sense now:

@verbatim{
 action:
 "P": "up" -> (0, 1)
 "P": "down" -> (0, -1)
 "P": "left" -> (-1, 0)
 "P": "right" -> (1, 0)
}

All of the actions are defined on the "P" entity, and all we have to change is the key and coordinate pair to have movement in four directions.