#lang typed/racket/gui
(require
  math/array
  "map.rkt")

(provide
 gui%)

(define hex-width 32)
(define hex-height 32)
(define tileset-bitmap
  (read-bitmap "images/drjamgo_modified.png" 'png/alpha))

(struct point ([x : Integer] [y : Integer]))

(: offset (-> Integer point))
(define (offset r)
  (if (zero? (remainder r 2))
      (point 0 (quotient (* hex-height 3) 4))
      (point (quotient hex-width 2) (quotient (* hex-height 3) 4))))

(: tile-pos (-> (Vectorof Index) point))
(define (tile-pos js)
  (let ([r : Integer (vector-ref js 0)]
        [c : Integer (vector-ref js 1)])
    (point
     (+ (point-x (offset r)) (* c hex-width))
     (* r (point-y (offset r))))))

(: draw-map (-> (Array Symbol) (Instance Canvas%) (Instance DC<%>) Void))
(define (draw-map tile-map canvas dc)
  (array-map
   (λ: ([js : (Vectorof Index)])
     (let ([s : Symbol (array-ref tile-map js)]
           [p : point (tile-pos js)])
       (cond
         [(equal? s 'land) (begin
                             (send dc draw-bitmap-section tileset-bitmap (point-x p) (point-y p) (* 0 hex-width) (* 0 hex-height) hex-width hex-height))]
         [(equal? s 'water) (begin
                              (send dc draw-bitmap-section tileset-bitmap (point-x p) (point-y p) (* 3 hex-width) (* 1 hex-height) hex-width hex-height))]
         [(equal? s 'beach) (begin
                              (send dc draw-bitmap-section tileset-bitmap (point-x p) (point-y p) (* 3 hex-width) (* 3 hex-height) hex-width hex-height))]
         [(equal? s 'mountain) (begin
                                 (send dc draw-bitmap-section tileset-bitmap (point-x p) (point-y p) (* 0 hex-width) (* 0 hex-height) hex-width hex-height)
                                 (send dc draw-bitmap-section tileset-bitmap (point-x p) (point-y p) (* (+ 0 1) hex-width) (* (+ 1 0) hex-height) hex-width hex-height))]
         [(equal? s 'forest) (begin
                               (send dc draw-bitmap-section tileset-bitmap (point-x p) (point-y p) (* 0 hex-width) (* 0 hex-height) hex-width hex-height)
                               (send dc draw-bitmap-section tileset-bitmap (point-x p) (point-y p) (* (+ 1 0) hex-width) (* 0 hex-height) hex-width hex-height))]
         [(equal? s 'farm) (begin
                             (send dc draw-bitmap-section tileset-bitmap (point-x p) (point-y p) (* 0 hex-width) (* 0 hex-height) hex-width hex-height)
                             (send dc draw-bitmap-section tileset-bitmap (point-x p) (point-y p) (* 2 hex-width) (* 3 hex-height) hex-width hex-height))]
         [(equal? s 'city) (begin
                             (send dc draw-bitmap-section tileset-bitmap (point-x p) (point-y p) (* 0 hex-width) (* 0 hex-height) hex-width hex-height)
                             (send dc draw-bitmap-section tileset-bitmap (point-x p) (point-y p) (* (+ 0 0) hex-width) (* 3 hex-height) hex-width hex-height))])))
   (indexes-array (array-shape tile-map)))
  (void))

(define game-canvas%
  (class canvas%
    (init-field [focus : (Mutable-Vectorof Integer)]
                [tm : (Array Symbol)]
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
    (: tm (Array Symbol))
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
