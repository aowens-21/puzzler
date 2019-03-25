#lang br/quicklang

(require racket/gui/base)
(require racket/draw)
(require racket/set)
(require "./expander-helpers/game.rkt")
(require "./expander-helpers/renderer.rkt")

; The game's rendering component
(define renderer (new puzzler-renderer%))

; Our single game object which contains 
(define puzzler-game (new puzzler-game%
                          [renderer renderer]))

; Gui setup things
(define game-frame (new frame%
                        [label "Game"]
                        [width (get-field window-size renderer)]
                        [height (get-field window-size renderer)]))

; Need to override canvas so we have our key event handler function
(define canvas-with-events%
  (class canvas%
    (define/override (on-char key-event)
     (handle-key-press (send key-event get-key-code)))
    (super-new)))

; What will be called every time the draw callback is needed
(define (paint-to-canvas canvas dc)
  (send dc set-pen "black" 2 'solid)
  (send renderer draw-game-grid dc)
  (draw-game-state dc))

; The game canvas which handles input and drawing callback
(define game-canvas (new canvas-with-events%
                         [parent game-frame]
                         [paint-callback paint-to-canvas]))

; Macros for expansion
(define-macro (puzzler-module-begin PARSE-TREE)
  #'(#%module-begin
     PARSE-TREE))
(provide (rename-out [puzzler-module-begin #%module-begin]))                               

(define-macro (puzzler-program LINE ...)
  #'(void LINE ...))
(provide puzzler-program)

; Map macros, to build map data structure
(define-macro (puzzler-map-list MAP ...)
  #'(void MAP ...))
(provide puzzler-map-list)

(define-macro (puzzler-goal-map-list MAP ...)
  #'(void MAP ...))
(provide puzzler-goal-map-list)

; Inner map index is used during macro expansion
; of the rows to know what row of the map-vector
; to update.
(define inner-map-index 0)
; This is exactly the same but for the goal map
(define inner-goal-map-index 0)
; This tells us which map-vector and position table we are
; on during expansion. Starts at -1 because it will be incremented
; before rows are built (if it started at 0 then the first index
; would be 1).
(define current-map-being-built-index -1)
(define current-goal-map-being-built-index -1)

; Needed because we can't directly mutate inside macros
(define (increment-current-map-being-built-index!)
  (set! current-map-being-built-index (add1 current-map-being-built-index)))
(define (increment-current-goal-map-being-built-index!)
  (set! current-goal-map-being-built-index (add1 current-goal-map-being-built-index)))
(define (reset-inner-map-index!)
  (set! inner-map-index 0))
(define (reset-inner-goal-map-index!)
  (set! inner-goal-map-index 0))

(define-macro (puzzler-map ROW ...)
  (with-pattern ([CALLER-STX (syntax->datum caller-stx)])
    #'(let ([calling-pattern 'CALLER-STX])
        (send renderer setup-draw-calculations! (length (cdr calling-pattern)))
        (add-map-vector (length (cdr calling-pattern)))
        (increment-current-map-being-built-index!)
        (reset-inner-map-index!)
        ROW ...)))
(provide puzzler-map)

(define-macro (map-row CELL ...)
  #'(build-row CELL ...))
(provide map-row)

; Goal map macros, set up the goal position table
(define-macro (puzzler-goal-map ROW ...)
  #'(let ([a 3])
      (increment-current-goal-map-being-built-index!)
      (reset-inner-goal-map-index!)
      ROW ...))
(provide puzzler-goal-map)

(define-macro (goal-map-row CELL ...)
  #'(setup-goal-position-table CELL ...))
(provide goal-map-row)

; Draw macros, sets up char -> image map
(define-macro (draw-block RULE ...)
  #'(void RULE ...))
(provide draw-block)

(define-macro (draw-rule CHAR PATH)
  #'(send puzzler-game add-to-entity-image-table! CHAR PATH))
(provide draw-rule)

; Action (key presses) macros
(define-macro (action-block RULE ...)
  #'(void RULE ...))
(provide action-block)

(define-macro (action-rule ID INPUT DX DY)
  #'(send puzzler-game add-to-action-table! ID INPUT DX DY))
(provide action-rule)

; Interactions macros
(define-macro (interactions-block RULE ...)
  #'(void RULE ...))
(provide interactions-block)

(define-macro (interaction-rule ACTOR INTERACTION RECEIVER)
  #'(send puzzler-game add-to-interaction-table! ACTOR INTERACTION RECEIVER))
(provide interaction-rule)

; Win rule macros
(define-macro (win-block RULE ...)
  #'(void RULE ...))
(provide win-block)

(define-macro (win-rule FIRST-ID RULE SECOND-ID)
  #'(send puzzler-game add-to-win-rule-table! FIRST-ID RULE SECOND-ID))
(provide win-rule)

; Lose rule macros
(define-macro (lose-block RULE ...)
  #'(void RULE ...))
(provide lose-block)

(define-macro (lose-rule FIRST-ID RULE SECOND-ID)
  #'(send puzzler-game add-to-lose-rule-table! FIRST-ID RULE SECOND-ID))
(provide lose-rule)

; Events macros
(define-macro (events-block RULE ...)
  #'(void RULE ...))
(provide events-block)

(define-macro (event-rule ACTOR EVENT RESULT)
  #'(send puzzler-game add-to-event-table! ACTOR EVENT RESULT))
(provide event-rule)

; Helpers (calls generated by macros)
(define (add-map-vector len)
  (send puzzler-game add-map-vector-to-list! (make-vector len (vector "")))
  (send puzzler-game add-position-table-to-list! (make-hash))
  (send puzzler-game add-goal-position-table-to-list! (make-hash))
  (if (eq? (get-field initial-game-grid puzzler-game) void)
        (send puzzler-game set-initial-game-grid! (make-vector len (vector "")))
        (void)))

(define (build-row cell . rest)
  (let* ([cells (cons cell rest)]
         [setup-initial-state? (= current-map-being-built-index 0)])
    (for-each (lambda (cell x-pos)
                (cond
                  [(not (string=? cell "#"))
                   (send puzzler-game add-to-position-table! current-map-being-built-index cell x-pos inner-map-index)
                   (if setup-initial-state?
                       (send puzzler-game add-to-initial-position-table! cell x-pos inner-map-index)
                       (void))]
                  [else (void)]))
              cells (build-list (length cells) values))
    (send puzzler-game add-to-map-vector! current-map-being-built-index inner-map-index (list->vector cells))
    (if setup-initial-state?
        (vector-set! (get-field initial-game-grid puzzler-game) inner-map-index (list->vector cells))
        (void))
    (set! inner-map-index (add1 inner-map-index))))

(define (setup-goal-position-table cell . rest)
  (let ([cells (cons cell rest)])
    (for-each (lambda (cell x-pos)
                (cond
                  [(not (string=? cell "#"))
                   (send puzzler-game add-to-goal-position-table! current-goal-map-being-built-index cell x-pos inner-goal-map-index)]
                  [else (void)]))
              cells (build-list (length cells) values))
    (set! inner-goal-map-index (add1 inner-goal-map-index))))

(define (draw-game-state dc)
  (let* ([image-table (get-field entity-image-table puzzler-game)]
         [block-size (get-field block-size renderer)]
         [block-positions (get-field block-positions renderer)]
         [goal-position-table (get-field current-goal-position-table puzzler-game)])
    (send dc set-brush "black" 'solid)
    (if (not (hash-empty? goal-position-table))
        (draw-goal-positions dc image-table block-size block-positions)
        (void))
    (for-each (lambda (y-draw grid-row)
                (for-each (lambda (x-draw grid-space)
                            (if (and (hash-has-key? image-table grid-space) (not (string=? grid-space "#")))
                                (let ([path (hash-ref image-table grid-space)])
                                  (if (string=? path "rect")
                                      (send dc draw-rectangle x-draw y-draw block-size block-size)
                                      (send dc draw-bitmap (get-scaled-bitmap path block-size) x-draw y-draw)))
                                (void)))
                          block-positions (vector->list grid-row)))
              block-positions (vector->list (get-field current-map-vector puzzler-game))))
  (send dc set-brush "white" 'solid))

(define (get-scaled-bitmap path block-size)
  (let* ([original-bitmap (read-bitmap path)]
         [pixel-width (send original-bitmap get-width)]
         [scale (/ pixel-width block-size)])
    (read-bitmap path #:backing-scale scale)))

; Goes through the goal position table and draws the sprites for the objects in their
; goal positions at some degree of transparency
(define (draw-goal-positions dc image-table block-size block-positions)
  (let ([goal-position-table (get-field current-goal-position-table puzzler-game)])
    (for-each (lambda (key)
                (for-each (lambda (pos)
                            (let* ([path (hash-ref image-table key)]
                                   [x (first pos)]
                                   [y (second pos)]
                                   [x-draw (list-ref block-positions x)]
                                   [y-draw (list-ref block-positions y)])
                              (cond
                                [(string=? path "rect")
                                 (send dc set-alpha 0.25)
                                 (send dc draw-rectangle x-draw y-draw block-size block-size)
                                 (send dc set-alpha 1)]
                                [else
                                 (send dc set-alpha 0.6)
                                 (send dc draw-bitmap (read-bitmap path) x-draw y-draw)
                                 (send dc set-alpha 1)])))
                          (hash-ref goal-position-table key)))
                (hash-keys goal-position-table))))
                                 
(define (proceed-with-movement id x y dx dy)
  (hash-set! (get-field current-position-table puzzler-game) id
             (map (lambda (pos)
                    (cond
                      [(and (= (first pos) x) (= (second pos) y))
                       (send puzzler-game update-grid-space! "#" (first pos) (second pos))
                       (send puzzler-game update-grid-space! id (+ (first pos) dx) (- (second pos) dy))
                       (list (+ (first pos) dx) (- (second pos) dy))]
                      [else
                       (list (first pos) (second pos))]))
                  (hash-ref (get-field current-position-table puzzler-game) id))))

(define (can-push? id x y dx dy)
  (let* ([interaction-table (get-field interaction-table puzzler-game)]
         [dest-x (+ x dx)]
         [dest-y (- y dy)]
         [dest-val (send puzzler-game get-grid-space dest-x dest-y)]
         [dest-val-empty? (string=? dest-val "#")])
    (cond
      [dest-val-empty? (proceed-with-movement id x y dx dy) #t]
      [(not (send puzzler-game in-bounds? dest-x dest-y)) #f]
      [(string=? (interaction-rule-str (car (filter (lambda (i) (string=? dest-val (interaction-receiver i))) (hash-ref interaction-table id)))) "grab") (proceed-with-movement id x y dx dy) #t]
      [(not (string=? (interaction-rule-str (car (filter (lambda (i) (string=? dest-val (interaction-receiver i))) (hash-ref interaction-table id)))) "push")) #f]
      [(can-push? id dest-x dest-y dx dy)
       (proceed-with-movement id x y dx dy) #t]
      [else #f])))
       
(define (handle-key-press key)
  (let ([key-str (~a key)]
        [action-table (get-field action-table puzzler-game)]
        [interaction-table (get-field interaction-table puzzler-game)])
    (cond
      [(string=? key-str "r")
       (send puzzler-game restart-game)]
      [(and (not (get-field lose-flag puzzler-game)) (hash-has-key? action-table key-str))
       (for-each (lambda (action)
                   (let* ([id (action-entity action)]
                          [dx (string->number (action-dx action))]
                          [dy (string->number (action-dy action))])
                     (hash-set! (get-field current-position-table puzzler-game) id
                                (map (lambda (pos)
                                       (let* ([x (first pos)]
                                              [y (second pos)]
                                              [dest-x (+ x dx)]
                                              [dest-y (- y dy)]
                                              [dest-val (send puzzler-game get-grid-space dest-x dest-y)]
                                              [interaction (filter (lambda (i) (string=? dest-val (interaction-receiver i))) (hash-ref interaction-table id))]
                                              [on-exit-action (filter (lambda (i) (string=? "onexit" (interaction-rule-str i))) (hash-ref interaction-table id))] 
                                              [dest-val-empty? (string=? dest-val "#")]
                                              [has-interaction? (> (length interaction) 0)]) 
                                         (cond
                                           [(and has-interaction? (and (string=? (interaction-rule-str (car interaction)) "push") (can-push? dest-val dest-x dest-y dx dy)))
                                            (send puzzler-game update-grid-space! "#" x y)
                                            (send puzzler-game update-grid-space! id dest-x dest-y)
                                            ; Trigger events must be called after all other movement logic for this pass
                                            (trigger-events id x y)
                                            (list dest-x dest-y)]
                                           [(and has-interaction? (string=? (interaction-rule-str (car interaction)) "grab"))
                                            (send puzzler-game update-grid-space! "#" x y)
                                            (send puzzler-game remove-from-current-position-table! (interaction-receiver (car interaction)) dest-x dest-y)
                                            (send puzzler-game update-grid-space! id dest-x dest-y)
                                            (trigger-events id x y)                                     
                                            (list dest-x dest-y)]
                                           [dest-val-empty?
                                            (send puzzler-game update-grid-space! "#" x y)
                                            (send puzzler-game update-grid-space! id dest-x dest-y)
                                            (trigger-events id x y)
                                            (list dest-x dest-y)]
                                           [else
                                            (list (first pos) (second pos))])))
                                     (hash-ref (get-field current-position-table puzzler-game) id)))))
                 (hash-ref action-table key-str))]
      [else (void)]))
  (handle-win-rules)
  (check-goal-position-table)
  (handle-lose-rules)
  (send game-canvas refresh-now))

; Performs all events for a given actor entity
(define (trigger-events actor x y)
  (let ([event-table (get-field event-table puzzler-game)])
    (if (hash-has-key? event-table actor)
        (for-each (lambda (event) (trigger-event actor x y event)) (hash-ref event-table actor))
        (void))))

; Performs actions for a single event
(define (trigger-event actor x y event)
  (let* ([rule (event-rule-str event)]
         [result (event-result event)])
    (cond
      [(string=? rule "onexit")
       (send puzzler-game update-grid-space-and-position-table! result x y)])))

(define (handle-win-rules)
  (let* ([win-rule-table (get-field win-rule-table puzzler-game)]
         [won? (get-field win-flag puzzler-game)])
    (cond
      [won?
       (writeln "YOU WIN!!!")]
      [else
       (cond
         [(check-goal-position-table)
          (advance-level-or-win)
          (void)]
         [else
          (for-each (lambda (rule)
                      (cond
                        [(string=? rule "count_items")
                         (if (count-items-rule-fulfilled? (hash-ref win-rule-table rule))
                             (advance-level-or-win)
                             (void))]
                        [(string=? rule "straight_path_to")
                         (if (straight-path-to-rule-fulfilled? (hash-ref win-rule-table rule))
                             (advance-level-or-win)
                             (void))]
                        [else void]))
                    (hash-keys win-rule-table))])])))

(define (advance-level-or-win)
  (let* ([maps-left (- (get-field maps-left puzzler-game) 1)])
    (if (> maps-left 0)
        (send puzzler-game advance-level)
        (send puzzler-game set-game-win-flag! #t))))

(define (check-goal-position-table)
  (let* ([goal-position-table (get-field current-goal-position-table puzzler-game)]
         [position-table (get-field current-position-table puzzler-game)]
         [won? #t])
    (cond
      [(hash-empty? goal-position-table) (set! won? #f)]
      [else
       (for-each (lambda (entity)
                   (let ([current-entity-positions (list->set (hash-ref position-table entity))])
                   (for-each (lambda (pos)
                               (if (set-member? current-entity-positions pos)
                                   (void)
                                   (set! won? #f)))
                             (hash-ref goal-position-table entity))))
                 (hash-keys goal-position-table))])
    won?))

(define (handle-lose-rules)
  (let* ([lose-rule-table (get-field lose-rule-table puzzler-game)])
    (if (get-field lose-flag puzzler-game)
        (writeln "YOU LOSE!!!")
        (for-each (lambda (rule)
                    (cond
                      [(string=? rule "count_items")
                       (if (count-items-rule-fulfilled? (hash-ref lose-rule-table rule))
                           (send puzzler-game set-game-lose-flag! #t)
                           (void))]
                      [(string=? rule "straight_path_to")
                       (if (straight-path-to-rule-fulfilled? (hash-ref lose-rule-table rule))
                           (send puzzler-game set-game-lose-flag! #t)
                           (void))]
                      [else void]))
                  (hash-keys lose-rule-table)))))

(define (count-items-rule-fulfilled? id-list)
  (let ([fulfilled? #f])
  (for-each (lambda (ids)
              (let* ([first-id (first ids)]
                     [second-id (second ids)]
                     [target-count (string->number second-id)]
                     [object-positions (hash-ref (get-field current-position-table puzzler-game) first-id)])
                (if (= target-count (length object-positions))
                    (set! fulfilled? #t)
                    (void))))
            id-list)
    fulfilled?))

(define (straight-path-to-rule-fulfilled? id-list)
  (let ([fulfilled? #f])
  (for-each (lambda (ids)
              (let* ([first-id (first ids)]
                     [second-id (second ids)]
                     [first-id-positions (hash-ref (get-field current-position-table puzzler-game) first-id)]
                     [second-id-positions (hash-ref (get-field current-position-table puzzler-game) second-id)])
                (for-each (lambda (pos)
                            (let* ([x (first pos)]
                                   [y (second pos)]
                                   [second-id-positions-in-same-row-or-col (filter (lambda (l) (or (= x (first l)) (= y (second l)))) second-id-positions)])
                              (for-each (lambda (second-id-pos)
                                          (if (= x (first second-id-pos))
                                              (if (straight-path-same-x? x y (second second-id-pos))
                                                  (set! fulfilled? #t)
                                                  (void))
                                              (if (straight-path-same-y? y x (first second-id-pos))
                                                  (set! fulfilled? #t)
                                                  (void))))
                                        second-id-positions-in-same-row-or-col)))
                          first-id-positions)))
            id-list)
    fulfilled?))

(define (straight-path-same-x? x start-y end-y)
  (cond
    [(= (abs (- start-y end-y)) 1)
     #t]
    [(> start-y end-y)
     (x-path-exists? x (+ end-y 1) start-y)]
    [(< start-y end-y)
     (x-path-exists? x (+ start-y 1) end-y)]))

(define (x-path-exists? x current-y end-y)
  (cond
    [(= current-y end-y)
     #t]
    [(not (string=? "#" (send puzzler-game get-grid-space x current-y)))
     #f]
    [else (x-path-exists? x (+ current-y 1) end-y)]))

(define (straight-path-same-y? y start-x end-x)
  (cond
    [(= (abs (- start-x end-x)) 1)
     #t]
    [(> start-x end-x)
     (y-path-exists? y (+ end-x 1) start-x)]
    [(< start-x end-x)
     (y-path-exists? y (+ start-x 1) end-x)]))

(define (y-path-exists? y current-x end-x)
  (cond
    [(= current-x end-x)
     #t]
    [(not (string=? "#" (send puzzler-game get-grid-space current-x y)))
     #f]
    [else (y-path-exists? y (+ current-x 1) end-x)]))

(define (same-position? pos-list1 pos-list2)
  (let* ([pos-set1 (list->set pos-list1)]
         [pos-set2 (list->set pos-list2)]
         [same-positions (set-intersect pos-set1 pos-set2)])
    (> (set-count same-positions) 0)))

(send game-frame show #t)
