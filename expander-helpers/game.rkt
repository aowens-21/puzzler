#lang racket

; Terminology:
;
; Entity - a single character which will be rendered in the game, defined in the draw section
; Map - A 2D grid represented as a vector of vectors
; Action - A movement rule, holds an entity and the dx and dy of the movement
; Interaction - A structure which holds a verb and two entities, one being the entity initiating the interaction and one
;               being the entity acted upon. Interactions happen when one entity tries to move into a square with another
;               entity in the square already.
; Event - A structure similar to interactions but it is used for triggers in the game that aren't caused by
;         one entity moving into a square with another.
; Win Rule - A rule which triggers the game win flag to be true

; Structure for an action which holds an entity, and dx/dy
(struct action (entity dx dy))
(provide action-entity action-dx action-dy)

; Structure for interactions which hold a string rule and a receiver
(struct interaction (rule-str receiver))
(provide interaction-rule-str interaction-receiver)

; Structure for events
(struct event (rule-str result))
(provide event-rule-str event-result)

(define puzzler-game%
  (class object%
    (init-field renderer) ; Our renderer component
    (field [win-flag #f]
           [lose-flag #f]
           [map-vector (vector "")] ; A vector of vectors representing the 2D grid of the game
           [entity-image-table (make-hash)] ; A hash table mapping entities to their drawable image path
           [action-table (make-hash)] ; A hash table mapping keyboard inputs to actions
           [position-table (make-hash)] ; A hash table mapping entities (characters) to a list of coordinate (x,y) pairs
           [interaction-table (make-hash)] ; A hash table mapping an initiating entity to a verb and an acted upon entity
           [event-table (make-hash)] ; A hash table mapping an entity to all of its events
           [win-rule-table (make-hash)] ; A hash table mapping a rule to a pair of entities
           [lose-rule-table (make-hash)] ; A hash table mapping a rule to a pair of entities
           [initial-position-table (make-hash)] ; The position table at the start of the game
           [initial-game-grid void]) ; The map vector at the start of the game
    ; Setting the game's map vector, which is the representation of
    ; a 2D grid as a vector of vectors.
    (define/public (set-map-vector! new-map-vector)
      (set-field! map-vector this new-map-vector))
    ; Setting the position table, a hash table mapping entities
    ; to a coordinate (x,y) pair.
    (define/public (set-position-table! new-position-table)
      (set-field! position-table this new-position-table))
    ; Adding an entry to the position table, which updates if a key
    ; exists or creates a new entry if the key doesn't.
    (define/public (add-to-position-table! entity x y)
      (if (hash-has-key? position-table entity)
      (hash-set! position-table entity (append (hash-ref position-table entity) (list (list x y))))
      (hash-set! position-table entity (list (list x y)))))
    ; Removing an entry from the position table.
    (define/public (remove-from-position-table! entity x y)
      (let* ([entity-positions (hash-ref position-table entity)]
             [positions-without-target-pos (remove (list x y) entity-positions)])
        (hash-set! position-table entity positions-without-target-pos)))
    ; Adding an entry to the entity image table
    (define/public (add-to-entity-image-table! entity path)
      (let* ([stripped-entity (string-replace entity "\"" "")]
             [stripped-path (string-replace path "\"" "")])
        (if (hash-has-key? entity-image-table stripped-entity)
            (error "Duplicate image characters defined!")
            (hash-set! entity-image-table stripped-entity stripped-path))))
    ; Adding an entry to the action table
    (define/public (add-to-action-table! entity key dx dy)
      (let* ([stripped-entity (string-replace entity "\"" "")]
             [stripped-key (string-replace key "\"" "")])
        (cond
          [(hash-has-key? action-table stripped-key) (hash-set! action-table stripped-entity (append (hash-ref action-table stripped-key) (action stripped-entity dx dy)))]
          [else (hash-set! action-table stripped-key (list (action stripped-entity dx dy)))])))
    ; Adding an entry to the interaction table
    (define/public (add-to-interaction-table! actor rule receiver)
      (let* ([stripped-actor (string-replace actor "\"" "")]
             [stripped-receiver (string-replace receiver "\"" "")])
        (if (hash-has-key? interaction-table stripped-actor)
            (hash-set! interaction-table stripped-actor (append (hash-ref interaction-table stripped-actor) (list (interaction rule stripped-receiver))))
            (hash-set! interaction-table stripped-actor (list (interaction rule stripped-receiver))))))
    ; Adding an entry to the win rule table
    (define/public (add-to-win-rule-table! first-entity rule second-entity)
      (let* ([stripped-first-entity (string-replace first-entity "\"" "")]
             [stripped-second-entity (string-replace second-entity "\"" "")])
        (if (hash-has-key? win-rule-table rule)
            (hash-set! win-rule-table rule (append (hash-ref win-rule-table rule) (list (list stripped-first-entity stripped-second-entity))))
            (hash-set! win-rule-table rule (list (list stripped-first-entity stripped-second-entity))))))
    ; Adding entry to the lose rule table
    (define/public (add-to-lose-rule-table! first-entity rule second-entity)
      (let* ([stripped-first-entity (string-replace first-entity "\"" "")]
             [stripped-second-entity (string-replace second-entity "\"" "")])
        (if (hash-has-key? lose-rule-table rule)
            (hash-set! lose-rule-table rule (append (hash-ref lose-rule-table rule) (list (list stripped-first-entity stripped-second-entity))))
            (hash-set! lose-rule-table rule (list (list stripped-first-entity stripped-second-entity))))))
    ; Adding an entry to the event table
    (define/public (add-to-event-table! actor rule result)
      (let* ([stripped-actor (string-replace actor "\"" "")]
             [stripped-result (string-replace result "\"" "")])
        (if (hash-has-key? event-table stripped-actor)
            (hash-set! event-table stripped-actor (append (hash-ref event-table stripped-actor) (list (event rule stripped-result))))
            (hash-set! event-table stripped-actor (list (event rule stripped-result))))))
    ; Sets the game win flag
    (define/public (set-game-win-flag! val)
      (set-field! win-flag this val))
    ; Setting game lose flag
    (define/public (set-game-lose-flag! val)
      (set-field! lose-flag this val))
    ; Updates a grid space on the map vector
    (define/public (update-grid-space! val x y)
      (vector-set! (vector-ref map-vector y) x val))
    ; Updates the map-vector and position table simultaneously
    (define/public (update-grid-space-and-position-table! val x y)
      (update-grid-space! val x y)
      (add-to-position-table! val x y))
    ; Sets the initial map-vector to the given value
    (define/public (set-initial-game-grid! new-map-vector)
      (set-field! initial-game-grid this new-map-vector))
    ; Adds a value to the game's initial position table
    (define/public (add-to-initial-position-table! val x y)
      (if (hash-has-key? initial-position-table val)
          (hash-set! initial-position-table val (append (hash-ref initial-position-table val) (list (list x y))))
          (hash-set! initial-position-table val (list (list x y)))))
    ; Restarts the game by setting values back to initial versions of the values
    (define/public (restart-game)
      ; A little confusing, but we have to copy the outer vector, then map the copy function
      ; over the inner vectors to make sure we don't assign the current map-vector to reference
      ; the initial game grid copy. Otherwise we would only be able to restart once, and then
      ; it would start changing the initial grid copy.
      (let* ([init-copy-outer (vector-copy initial-game-grid)]
             [init-total-copy (vector-map vector-copy init-copy-outer)])
        (set-map-vector! init-total-copy)
        (set-position-table! (hash-copy initial-position-table))
        (set-game-win-flag! #f)
        (set-game-lose-flag! #f)))
    ; Sets the game's renderer component, which will be an instance of the puzzler-renderer% class
    (define/public (set-renderer! new-renderer)
      (set-field! renderer this new-renderer))
    ; Checks if a specific coordinate pair is within the bounds of the map
    (define/public (in-bounds? x y)
      (and (>= x 0) (>= y 0) (< x (get-field grid-size renderer)) (< y (get-field grid-size renderer))))
    ; Returns the entity that is in the given grid space
    (define/public (get-grid-space x y)
      (cond
        [(in-bounds? x y) (vector-ref (vector-ref map-vector y) x)]
        [else "OOB"]))
    (super-new)))
(provide puzzler-game%)