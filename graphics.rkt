#lang typed/racket/gui
(require
  math/array
  "map.rkt")

(provide
 gui%)

(define hex-width 35)
(define hex-height 30)
(define land-bitmap
  (read-bitmap "images/hex_grass_large.png" 'png/alpha))
(define water-bitmap
  (read-bitmap "images/hex_water_large.png" 'png/alpha))
(define mountain-bitmap
  (read-bitmap "images/hex_mountain_large.png" 'png/alpha))
(define forest-bitmap
  (read-bitmap "images/hex_forest_large.png" 'png/alpha))
(define beach-bitmap
  (read-bitmap "images/hex_beach_large.png" 'png/alpha))

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
           [(equal? s 'land) (send dc draw-bitmap land-bitmap (point-x p) (point-y p))]
           [(equal? s 'water) (send dc draw-bitmap water-bitmap (point-x p) (point-y p))]
           [(equal? s 'beach) (send dc draw-bitmap beach-bitmap (point-x p) (point-y p))]
           [(equal? s 'mountain) (begin
                                   (send dc draw-bitmap land-bitmap (point-x p) (point-y p))
                                   (send dc draw-bitmap mountain-bitmap (point-x p) (- (point-y p) 10)))]
           [(equal? s 'forest) (begin
                                   (send dc draw-bitmap land-bitmap (point-x p) (point-y p))
                                   (send dc draw-bitmap forest-bitmap (point-x p) (- (point-y p) 5)))])))
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
