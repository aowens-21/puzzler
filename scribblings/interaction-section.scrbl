#lang scribble/manual

@title{Interactions and Events}

A game world without any interactivity would be very boring, and that's where Puzzler's @italic{interaction section} comes in. The @italic{interaction section} is where the interactions
between entities are defined. In Puzzler, an interaction is what happens when one entity tries to move into the space that is occupied by another entity.

@section{Interaction Rules}

Defining @italic{interaction rule}s in Puzzler is similar to defining other types of rules, we start off with some symbol denoting the start of the @italic{interaction section} and then list
each rule on its own line:

@verbatim{
 interactions:
 <interaction_rule>
 ...
}

These @italic{interaction rule}s consist of three parts: the acting entity (the one moving and thus triggering the interaction), the @italic{interaction verb}, and the entity being acted upon. The
entities are represented by a single character, as usual, such as "P" or "B". The @italic{interaction verb} can be one of three words: push, stop, or grab. These are the three types of interaction
in Puzzler and they are shown in the example below:

@verbatim{
 interactions:
 "P" push "B"
 "B" stop "B"
 "P" grab "T"
}

The first rule in this example says that whenever our "P" entity moves into a space where a "B" is occupying, the "P" will push the "B" in whatever direction "P" is moving in. It is important to
note that @bold{entities cannot be pushed outside the bounds of the map}.

The second rule might seem a little confusing, but imagine for a second that in our game "B" means "box" and there are multiple boxes on the map. If our "P" can go pushing boxes around all day long,
we might want it so that if a "P" tries to push two boxes at a time (that is, push one box into a space occupied by another), the second box will stop the first. That is all this rule is stating: boxes
cannot push other boxes. Interestingly enough, we could change this rule to @italic{"B" push "B"}, and our "P" entity would be able to push multiple boxes at a time.

The final rule, "grab", could just as accurately be called "replace". When "P" moves into the space occupied by "T", it will "grab" it and thus remove it from the game's map. This can be useful if you want
a game where your player has to navigate some puzzle and upon solving it they "grab" a trophy to win the game.

@subsection{Conflicting Interactions}

After having seen a few interactions, you may thing "push is the opposite of stop, so what happens if I define them both?" While this is an interesting question, the answer is pretty boring: @bold{Puzzler takes
the first interaction and will ignore the rest}. For example:

@verbatim{
 interactions:
 "P" push "B"
 "P" stop "B"
}

In this particular @italic{interaction section}, the second rule will never actually be triggered because when a "P" moves into a space with a "B", Puzzler will see that there is a "push" interaction defined
and it will trigger that.

@section{Events (Well, just Event Really)}

Puzzler has a somewhat obscure and situational feature called the @italic{event section}. This is defined much the same as all of the other sections, and it only has one supported "type" at the moment.
It is best to explain events with an example:

@verbatim{
 events:
 "P" onexit "B"
}

This event, called @italic{onexit}, looks a lot like an @italic{interaction}. The difference is that this event triggers every time the first entity moves (thus the name, "onexit"). When the "P" entity
exits a space on the map, that space will be filled with the second entity ("B").

