#lang racket/base

(require "tokenizer.rkt" "parser.rkt")
(require syntax/strip-context)

(module+ reader
  (provide read-syntax))
(define (read-syntax path port)
  (define parse-tree (parse path (make-tokenizer port)))
  (strip-context
   #`(module puzzler-mod puzzler/expander
       #,parse-tree)))