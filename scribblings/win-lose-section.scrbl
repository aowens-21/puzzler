#lang scribble/manual

@title{Winning and Losing}

All games in Puzzler need some way to represent winning and losing, and these conditions are defined in the @italic{win section} and @italic{lose section}, respectively. In this section, we'll talk
about the different kinds of win/lose conditions supported by the Puzzler language.

@section{Defining Win Conditions}

The @italic{win section} follows the pattern of all the other Puzzler sections:

@verbatim{
 win:
 <win_rule>
 ...
}

Puzzler supports two types of win rules: @italic{count_items} and @italic{straight_path_to}. The @italic{count_items} takes a type of entity and a number and it is triggered when the number of
that particular entities on the map is equal to the supplied number. @italic{straight_path_to} takes two entities and is triggered when there is either a horizontal or vertical clear path
(unblocked by another entity) between the two entity types. For example:

@verbatim{
 win:
 "T" count_items 0
 "P" straight_path_to "E"
}

The first rule in this example counts the number of "T" entities on the map and changes the win state of the game to true if the count is zero. The second rule will trigger the win state if there is
any clear horizontal or vertical path between any "P" and "E" entities.

@subsection{Goal Maps}

There is another type of win condition in Puzzler, called a @italic{goal map}, which is defined in a different section from the other @italic{win rule}s. Goal maps are defined similarly to
@seclink["maps"]{regular maps}. Consider the following example:

@verbatim{
 START_GOAL_MAP
 ######
 P#####
 ######
 END_GOAL_MAP
}

If a goal map is defined in Puzzler, the game will compare the current map to the goal map every time the game state updates. If the current map ever matches the goal map, the game win state will be
set to true. In this example, we have essentially defined a new win condition stating that the "P" entity must be in the 2nd row and 1st column of the game's map. It is important to know that since
Puzzler supports multiple maps, @bold{the number of goal maps must equal the number of maps}.

@section{Defining Lose Conditions}

Lose conditions are extremely similar to win conditions, except that they are defined in a @italic{lose section}. The lose section looks like this:

@verbatim{
 lose:
 <lose_rule>
 ...
}

@italic{lose_rule}s support the same types as @italic{win_rule}s, which were described earlier. There is, however, currently @bold{no way to use a goal map to trigger a lose state in a Puzzler game}.

