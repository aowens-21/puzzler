#lang scribble/manual

@title[#:tag "maps"]{Maps}

Every game built with Puzzler will start with a @italic{map section}. This defines the "game world" so to speak, which is represented by
a grid of characters.

@section{Basic Map Rules}

Puzzler maps are made up of blank spaces and entities in the following form:

@verbatim{
 START_MAP
 <map_row>
 ...
 END_MAP
}

Where @italic{<map_row>} is a visual representation of a row on the grid, such as "###" or "#P#". Each @italic{<map_row>} is separated by a new line.
In Puzzler, a "#" character on the map means empty space, and any other character represents an entity in the game. For example:

@verbatim{
 START_MAP
 #####
 ##P##
 #####
}

The above map is a 5x3 grid with some entity "P" (by convention we make the player "P", but it could be anything) in the center of 2nd row. This
example illustrates an important example about Puzzler maps in that @bold{they do not have to be square}. We could have a 5x3, 5x5, 3x5, or even
a 1x1 (although that wouldn't be very interesting). It is important, however, to note that @bold{all rows must be the same length}. We cannot
do something like the following:

@verbatim{
 START_MAP
 ##P##
 ####
 ###
}

This would fail to build in Puzzler, as we are currently limited to making all Puzzler maps rectangular.

@section{Multiple Maps}

You can build games in Puzzler which have multiple levels, and the syntax is pretty simple, for example:

@verbatim{
 START_MAP
 P####
 #####
 #####

 #####
 ##P##
 #####

 #####
 #####
 ####P
 END_MAP
}

The above map section generates a Puzzler game with 3 levels which progress in the order that they are defined. While @italic{map_row}s are separated by newlines, maps are separated by a
blank line. Puzzler will continue to look for maps until it sees the @italic{@bold{END_MAP}} token. Games with multiple map definitions have the same rules as games with only one map, however,
it is important to know that @bold{all maps must be the same size}.
