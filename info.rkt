#lang info
(define version "1.0")
(define deps (list "beautiful-racket" "brag" "draw-lib" "gui-lib" "base" "parser-tools-lib"))
(define build-deps '("racket-doc" "scribble-lib"))
(define test-omit-paths (list "examples" "expander.rkt"))
(define collection "puzzler")
(define scribblings '(("scribblings/puzzler.scrbl")))