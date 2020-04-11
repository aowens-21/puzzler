#lang scribble/manual

@title{Drawing and Images}

Every game you build with Puzzler will have some images which represent entities in the game. In our @seclink["sokoban"]{Sokoban game}, for example, we had an image for
the player as well as an image for the boxes the player pushes around. Managing which images map to which game entities is the responsibility of our game's
@italic{draw section}.

@section{Draw Rules}

The Puzzler draw section looks like this:

@verbatim{
 draw:
 <draw_rule>
 ...
}

Where @italic{<draw_rule>} is of the form @italic{"<entity_character>" -> "<image_path>"}. Remember that in Puzzler every game entity is represented on the map as a single character like
"P" or "X". So, for example, if we wanted to draw some image @italic{"player.png"} for our game entity "P", we would do the following:

@verbatim{
 draw:
 "P" -> "player.png"
}

This can be read as something like "P draws player.png". It is important to remember that @bold{image paths are defined in relation to where the Puzzler game is executing}.

@section{Built-Ins}

There is one special case of draw rules in Puzzler: the reserved word @italic{"rect"}. Any entity which maps to "rect" in a draw rule will be drawn as a black box
the same size as a single grid square. In the Sokoban example we had:

@verbatim{
 draw:
 "P" -> "player.png"
 "B" -> "rect"
}

The first draw rule works normally and reads the image "player.png" from the current directory, but the second draw rule uses the built in shape "rect" to draw black boxes for all of the
well, boxes, in the game.


