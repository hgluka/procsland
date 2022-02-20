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

(: draw-map (-> (Array Symbol) (-> (Instance Canvas%) (Instance DC<%>) Void)))
(define (draw-map tile-map)
  (λ (canvas dc)
    (array-map
     (λ: ([js : (Vectorof Index)])
       (let ([s : Symbol (array-ref tile-map js)]
             [p : point (tile-pos js)])
         (cond
           [(equal? s 'land) (begin
                               (send dc draw-bitmap-section tileset-bitmap (point-x p) (point-y p) (* 0 hex-width) (* 0 hex-height) hex-width hex-height))]
           [(equal? s 'water) (begin
                                (send dc draw-bitmap-section tileset-bitmap (point-x p) (point-y p) (* 3 hex-width) (* (+ 0 1) hex-height) hex-width hex-height))]
           [(equal? s 'beach) (begin
                                (send dc draw-bitmap-section tileset-bitmap (point-x p) (point-y p) (* 3 hex-width) (* (+ 1 2) hex-height) hex-width hex-height))]
           [(equal? s 'mountain) (begin
                                   (send dc draw-bitmap-section tileset-bitmap (point-x p) (point-y p) (* 0 hex-width) (* 0 hex-height) hex-width hex-height)
                                   (send dc draw-bitmap-section tileset-bitmap (point-x p) (point-y p) (* (+ 0 (random 2)) hex-width) (* (+ 1 (random 2)) hex-height) hex-width hex-height))]
           [(equal? s 'forest) (begin
                                 (send dc draw-bitmap-section tileset-bitmap (point-x p) (point-y p) (* 0 hex-width) (* 0 hex-height) hex-width hex-height)
                                 (send dc draw-bitmap-section tileset-bitmap (point-x p) (point-y p) (* (+ 1 (random 2)) hex-width) (* 0 hex-height) hex-width hex-height))])))
     (indexes-array (array-shape tile-map)))
    (void)))

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
                [iterations : Integer])
    (: frame (Instance Frame%))
    (define frame
      (new frame%
           [label "procsland"]
           [style '(no-resize-border)]))
    (: tm (Array Symbol))
    (define tm (generate-map map-height map-width iterations land-mass mountain-mass forest-mass beach-mass))
    (: canvas (Instance Canvas%))
    (define canvas
      (new canvas%
           [parent frame]
           [min-width screen-width]
           [min-height screen-height]
           [paint-callback (draw-map tm)]))
    (send frame show #t)
    (super-new)))
