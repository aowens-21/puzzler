#lang scribble/manual

@title[#:tag "sokoban"]{An Example: Sokoban}

A Puzzler program generates a @racket[racket/gui] program based on various @italic{sections} specified by its author. In this example, we will be looking at a game built with Puzzler
called "Sokoban". @hyperlink["https://en.wikipedia.org/wiki/Sokoban"]{Sokoban} is a puzzle game in which the player must push boxes into specific locations on the map without blocking themselves or other boxes in and thus making the puzzle
impossible to solve. It was originally released in 1982, but has spawned numerous derivatives and varieties.

A screenshot of this game running on Puzzler (with my excellent programmer art) is below:
 
@centered{@image["sokoban.png" #:scale 0.5]}

@centered{Sokoban Game}

And the source code for this game in Puzzler is as follows:

@centered{@codeblock|{
  #lang puzzler
  
  START_MAP
  P#####
  ######
  ##BBB#
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
}|}

As you can see, Puzzler is more of a description language than a standard procedural-style programming language like you might be used to. Nevertheless,
it allows for quite a bit of expressiveness in a small package.

In the rest of this guide we will break down what makes this Sokoban example work, and how the various sections interact to generate a meaningful program.

@section{The Map Section}

All Puzzler programs begin with a @italic{map section}. Our @italic{map section} in Sokoban looks like this

@verbatim{
 START_MAP
 P#####
 ######
 ##BBB#
 ######
 ######
 ######
 END_MAP
}

The @italic{map section} starts with a line @italic{@bold{START_MAP}}, which denotes the beginning of the @italic{map section}. Each newline following this is considered
a new row in the grid. In this example you can see the first row is "P#####". The character "#" represents empty space in a Puzzler map, while all other character
are special entities within the game.

The "P" in this map represents the player, and similarly the "B" represents a box. It is easy to track which characters map to which entities by looking in the game's
@italic{draw section}, which we will cover in a bit.

The map section is closed with a line @italic{@bold{END_MAP}}, denoting that we are done describing the game's map.

@section{The Goal Map Section}

Many games---all games built with Puzzler---need a win condition. One way of describing a win condition in Puzzler is with a @italic{goal map section}.
The @italic{goal map section} in our Sokoban game looks very similar to a normal @italic{map section}:

@verbatim{         
 START_GOAL_MAP
 ######
 ######
 ######
 ##B###
 #B####
 B#####
 END_GOAL_MAP
}

The concept of a goal map is pretty simple. It essentially just says "if the map ever looks like this, then the game can be considered won". Different games may have different ways
for the map to change, but the principle of winning via a @italic{goal map section} stays the same. For our purposes in building Sokoban, this is the same thing as saying "The player has pushed all
the boxes into their designated locations".

@section{The Draw Section}

The purpose of the @italic{draw section} is to map the game entities on a Puzzler map to their image files. This also serves as a list of all the important entities within the game.
The @italic{draw section} consists of one or more @italic{draw rule}s, which associate an entity to an image file (whose path is relative to the current directory). In our Sokoban
example, the @italic{draw section} looks like this:

@verbatim{         
 draw:
 "P" -> "player.png"
 "B" -> "rect"
}

The first rule tells the Puzzler rendering system to draw the image "player.png" for every occurence of a "P" on the map. This is similar for the second rule, except that "rect" is a reserved
symbol within the context of a Puzzler draw rule. The rendering system will draw a black rectangle for every "rect" occurence in Puzzler. In Sokoban, all of the boxes("B") that the player pushes
are represented in this way.

@section{The Action Section}

So far we've only seen descriptions of the static elements of our Sokoban program, but it wouldn't be a game without some way to interact with the program's state. This is where the @italic{action section}
comes in. The @italic{action section} describes how the player interacts with the elements in the game through input. Similar to the @italic{draw section}, the @italic{action section} is broken down into
@italic{action rule}s, which describe how a given input changes the game's state. The @italic{action section} in the Sokoban example is as follows:

@verbatim{
 action:
 "P": "up" -> (0, 1)
 "P": "down" -> (0, -1)
 "P": "left" -> (-1, 0)
 "P": "right" -> (1, 0)
}

The syntax for an @italic{action rule} is straightforward, for example, the first rule in this example states that whenever the "up" key is pressed on the keyboard, any "P" entity (in this case the player)
will have its position changed by 0 in the X direction and 1 in the Y direction. The rest of the @italic{action rule}s are very similar, changing only the key and the DX/DY values. In this
game there is only one "P", but if there were multiple then these actions would be applied to all of the matched entities.

@section{The Interaction Section}

With the @italic{action section} we have seen how to let players interact with the game world, but how do entities interact with each other? These kinds of interactions are expressed via
the @italic{interaction section}. Sticking with Puzzler tradition, this section consists of one or more @italic{interaction rule}s. The interactions in Sokoban are expressed like so:

@verbatim{
 interactions:
 "P" push "B"
 "B" stop "B"
}

The way to read each of these rules is "When Entity1 collides with Entity2, X Interaction happens". So in the first rule, we have '"P" push "B"', which means that the entity "P" will "push" the entity
"B" upon collision. The "push" interaction is something built in to Puzzler which means that the entity being acted upon---in this case "B"---will be moved in whatever direction the entity acting upon
it---"P"---is moving in. Similarly, the second rule states that when a "B" entity interacts with another "B" entity, it will be "stopped". The "stop" interaction is also built in, which essentially just
blocks movement from happening.

@section{Wrapping Up: A Finished Game}

As you can see, we now have all the pieces to create a working version of the game Sokoban. We can describe maps, goal maps for where to push boxes, player input and movement, sprite rendering,
and interactions between game entities. This has all been done in roughly 30 lines of Puzzler code. More importantly, we can scale this example to produce more levels, entity types, and interactions
by simply adding a few more rules. This is the purpose of the Puzzler language, and hopefully you've seen that it's easy to express an interesting game without having to worry about too many complex
and interacting systems.

If you are looking for more information about the specifics of Puzzler, please check out the documentation for each of the different @italic{sections}. If you'd like to see more examples of games that
can be built with Puzzler, clone the source code on GitHub and run them yourself or view the documentation on the different examples.

Thanks for reading and have fun building puzzle games!