#lang racket

(define puzzler-renderer%
  (class object%
    (field [window-size 500] ; The actual size of the window on the GUI
           [margin 25] ; The space between grid squares
           [grid-size void] ; The number of rows/cols in the grid
           [block-size void] ; The size in pixels of each block (square) in the grid
           [block-positions (list)]) ; The positions in pixels to draw the squares for the grid outline
    (define/public (set-grid-size! new-grid-size)
      (set-field! grid-size this new-grid-size))
    (define/public (set-block-size! new-block-size)
      (set-field! block-size this new-block-size))
    (define/public (set-block-positions! new-block-positions)
      (set-field! block-positions this new-block-positions))
    ; Called by the expander macros to set up the different fields for the renderer
    (define/public (setup-draw-calculations! rows)
      (set-grid-size! rows)
      (set-block-size! (quotient (- window-size (* 2 margin)) grid-size))
      (set-block-positions! (build-list grid-size (lambda (i) (+ margin (* block-size i))))))
    ; Draws the game grid square by square
    (define/public (draw-game-grid dc)
      (let* ([grid-x-start 25]
             [grid-x-end (+ grid-x-start (- window-size 50))]
             [grid-y-start 25]
             [grid-y-end (+ grid-y-start (- window-size 50))])
        (send dc draw-rectangle grid-x-start grid-y-start (- window-size 50) (- window-size 50))
        (draw-rows dc grid-x-start grid-x-end grid-y-start grid-y-end grid-size)
        (draw-columns dc grid-x-start grid-x-end grid-y-start grid-y-end grid-size)))
    ; Helper to draw the grid's rows
    (define (draw-rows dc x-start x-end y-start y-end rows)
      (let* ([height (- y-end y-start)]
             [row-height (quotient height rows)] ; subtract 1 from rows because we need rows-1 lines
             [row-y-values (map (lambda (x) (+ y-start (* row-height x))) (build-list (- rows 1) (lambda (y) (+ y 1))))])
        (for-each (lambda (y-value)
                    (send dc draw-line x-start y-value x-end y-value))
                  row-y-values)))
    ; Helper to draw the grid's columns
    (define (draw-columns dc x-start x-end y-start y-end columns)
      (let* ([width (- x-end x-start)]
             [col-width (quotient width columns)]
             [col-x-values (map (lambda (x) (+ x-start (* col-width x))) (build-list (- columns 1) (lambda (y) (+ y 1))))])
        (for-each (lambda (x-value)
                    (send dc draw-line x-value y-start x-value y-end))
                  col-x-values)))
    (super-new)))
(provide puzzler-renderer%)