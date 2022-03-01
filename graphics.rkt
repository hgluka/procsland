#lang typed/racket/gui
(require
  math/array
  "map.rkt")

(provide
 gui%)

(define hex-width 32)
(define hex-height 32)
(define tileset-bitmap
  (read-bitmap "resources/images/drjamgo_modified.png" 'png/alpha))

(struct point ([x : Integer] [y : Integer]) #:type-name Point)

(: offset (-> Integer Point))
(define (offset r)
  (if (zero? (remainder r 2))
      (point 0 (quotient (* hex-height 3) 4))
      (point (quotient hex-width 2) (quotient (* hex-height 3) 4))))

(: tile-pos (-> (Vectorof Index) Point))
(define (tile-pos js)
  (let ([r : Integer (vector-ref js 0)]
        [c : Integer (vector-ref js 1)])
    (point
     (+ (point-x (offset r)) (* c hex-width))
     (* r (point-y (offset r))))))

(: draw-tile (-> Tile Point (Instance DC<%>) Boolean))
(define (draw-tile t p dc)
  (when (tile-draw-under t)
    (send dc draw-bitmap-section tileset-bitmap (point-x p) (point-y p) (* 0 hex-width) (* 0 hex-height) hex-width hex-height))
  (send dc draw-bitmap-section tileset-bitmap (point-x p) (point-y p) (* (tile-sheet-x t) hex-width) (* (tile-sheet-y t) hex-height) hex-width hex-height))

(: draw-map (-> (Array Tile) (Instance Canvas%) (Instance DC<%>) Void))
(define (draw-map tile-map canvas dc)
  (array-map
   (λ: ([js : (Vectorof Index)])
     (let ([s : Tile (array-ref tile-map js)]
           [p : Point (tile-pos js)])
       (draw-tile s p dc)))
   (indexes-array (array-shape tile-map)))
  (void))

(define game-canvas%
  (class canvas%
    (init-field [focus : (Mutable-Vectorof Integer)]
                [tm : (Array Tile)]
                [tm-width : Integer]
                [tm-height : Integer])
    (inherit refresh)
    (define/override (on-char ke)
      (case (send ke get-key-release-code)
        [(left) (begin
                 (vector-set! focus 1 (max 0 (- (vector-ref focus 1) 1)))
                 (refresh))]
        [(right) (begin
                  (vector-set! focus 1 (min tm-width (+ (vector-ref focus 1) 1)))
                  (refresh))]
        [(up) (begin
               (vector-set! focus 0 (max 0 (- (vector-ref focus 0) 1)))
               (refresh))]
        [(down) (begin
                 (vector-set! focus 0 (min tm-height (+ (vector-ref focus 0) 1)))
                 (refresh))]
        [else (void)]))

    (: game-paint-callback (-> (Instance Canvas%) (Instance DC<%>) Void))
    (define/private (game-paint-callback c dc)
                    (draw-map tm c dc)
                    (let ([inds (indexes-array (array-shape tm))])
                      (when (equal? (tile-type (array-ref tm focus)) 'city)
                        (send dc set-text-foreground "white")
                        (send dc set-text-background "black")
                        (send dc set-text-mode 'solid)
                        (send dc draw-text (tile-name (array-ref tm focus))
                              (+ (point-x (tile-pos (array-ref inds focus))) hex-width)
                              (+ hex-height (point-y (tile-pos (array-ref inds focus))))))
                      (send dc draw-bitmap-section tileset-bitmap
                            (point-x (tile-pos (array-ref inds focus)))
                            (point-y (tile-pos (array-ref inds focus)))
                            (* 0 hex-width) (* 5 hex-height)
                            hex-width hex-height))
                    (void))
    (super-new (paint-callback (lambda (c dc) (game-paint-callback c dc))))))


(define gui%
  (class object%
    (init-field [screen-width : Exact-Nonnegative-Integer]
                [screen-height : Exact-Nonnegative-Integer]
                [map-height : Integer]
                [map-width : Integer]
                [land-mass : Integer]
                [mountain-mass : Integer]
                [forest-mass : Integer]
                [beach-mass : Integer]
                [city-mass : Integer]
                [iterations : Integer])
    (: frame (Instance Frame%))
    (define frame
      (new frame%
           [label "procsland"]
           [style '(no-resize-border)]))
    (: tm (Array Tile))
    (define tm (generate-map map-height map-width iterations land-mass mountain-mass forest-mass beach-mass city-mass))

    (: focus (Mutable-Vectorof Integer))
    (define focus (vector 0 0))

    (: canvas (Instance Canvas%))
    (define canvas
      (new game-canvas%
           [focus focus]
           [tm tm]
           [tm-width (- map-width 1)]
           [tm-height (- map-height 1)]
           [parent frame]
           [min-width screen-width]
           [min-height screen-height]))
    (send frame show #t)
    (super-new)))
