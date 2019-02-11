#lang br
(require brag/support)
(require br-parser-tools/lex-sre)

(define (make-tokenizer port)
  (define (next-token)
    (define puzzler-lexer
      (lexer
        [(from/to "--" "\n") (next-token)]
        ["draw:" (token 'DRAW-TOKEN lexeme)]
        [(:: "\"" (:= 1 alphabetic) "\"")
         (token 'ID lexeme)]
        [(from/to "\"" "\"")
         (token 'STRING-TOKEN lexeme)]
        ["action:" (token 'ACTION-TOKEN)]
        ["win:" (token 'WIN-TOKEN)]
        ["lose:" (token 'LOSE-TOKEN)]
        ["interactions:" (token 'INTERACTIONS-TOKEN)]
        ["events:" (token 'EVENTS-TOKEN)]
        ["push" (token 'PUSH-TOKEN lexeme)]
        ["stop" (token 'STOP-TOKEN lexeme)]
        ["grab" (token 'GRAB-TOKEN lexeme)]
        ["onexit" (token 'ONEXIT-TOKEN lexeme)]
        ["count_items" (token 'COUNT-ITEMS-TOKEN lexeme)]
        ["straight_path_to" (token 'STRAIGHT-PATH-TO-TOKEN lexeme)]
        ["==" (token 'EQUALS-TOKEN lexeme)]
        ["\n" (token 'NEWLINE-TOKEN lexeme)]
        [whitespace (token lexeme #:skip? #t)]
        ["START_MAP" (token 'START-MAP-TOKEN lexeme)]
        ["END_MAP" (token 'END-MAP-TOKEN lexeme)]
        ["->" (token 'RULE-RESULT-TOKEN lexeme)]
        [(or (:= 1 alphabetic) (:= 1 "#"))
         (token 'MAP-CHAR-TOKEN lexeme)]
        [(or (:= 1 numeric) (:: "-" (:= 1 numeric)))
         (token 'NUM-TOKEN lexeme)]
        [any-char (token lexeme)]))
    (puzzler-lexer port))
  next-token)

(provide make-tokenizer)