#lang scribble/manual

@title{Conclusion and Future Work}

Hopefully by now you've seen what Puzzler is capable of. I would encourage you to go check out the examples on the Puzzler github page to see how these different pieces can be put together
to build interesting games. I would also encourage you to take a look at Steven Lavelle's @hyperlink["https://www.puzzlescript.net/"]{PuzzleScript} language, which inspired the design of Puzzler
significantly. It is a good tool for web-based puzzle games rather than the desktop ones you can create with Puzzler.

While it's true that Puzzler is already expressive enough to represent a variety of puzzle games, there is plenty of future work to improve both its expressiveness and robustness. The Puzzler system is
very limited in its number of interactions and win/lose conditions, and a larger set would increase the expressiveness of the language. Another interesting project would be to implement a custom interaction
system which would allow the user to define things like @italic{push} and @italic{stop} themselves.

If you are interested in using Puzzler for something it can't currently express, feel free to submit a pull request, issue, or even fork the project and develop against it yourself. I am not "actively"
working on new features for Puzzler, but I would be happy to engage with anyone interested in Puzzler or game development with Racket in general!