#lang typed/racket
(require math/array)

(provide generate-map)

(: tile-map (-> Integer (Array Symbol)))
(define (tile-map n)
  (make-array (vector n n) 'empty))

(: initialize (-> (Array Symbol) Integer (Array Symbol)))
(define (initialize tile-map land-mass)
  (array-map
   (λ: ([x : Symbol])
     (if (< (random 100) land-mass)
         'land
         'water))
   tile-map))

(: count-tiles (-> (Array Symbol) Symbol Integer Integer Integer))
(define (count-tiles tile-map tile x y)
  (array-count
   (λ: ([s : Symbol])
     (equal? s tile))
   (let ([size : Integer (- (vector-ref (array-shape tile-map) 1) 1)])
     (array-indexes-ref
      tile-map
      (array #[(vector (min (+ x 1) size) y)
               (vector x (min (+ y 1) size))
               (vector (max (- x 1) 0) y)
               (vector x (max (- y 1) 0))
               (vector (min (+ x 1) size) (min (+ y 1) size))
               (vector (max (- x 1) 0) (max (- y 1) 0))
               (vector (max (- x 1) 0) (min (+ y 1) size))
               (vector (min (+ x 1) size) (max (- y 1) 0))])))))

; (count-tiles tile-map 'land (vector-ref js 0) (vector-ref js 1))
(: one-step (-> (Array Symbol) (Array Symbol)))
(define (one-step tile-map)
  (array-map
   (λ: ([js : (Vectorof Index)])
     (let ([s : Symbol (array-ref tile-map js)])
       (cond
         [(and (equal? s 'land)
               (< (count-tiles tile-map 'land (vector-ref js 0) (vector-ref js 1)) 2))
          'water]
         [(and (equal? s 'land)
               (< (count-tiles tile-map 'land (vector-ref js 0) (vector-ref js 1)) 5))
          'land]
         [(equal? s 'land) 'water]
         [(equal? s 'water) (if (< (count-tiles tile-map 'land (vector-ref js 0) (vector-ref js 1)) 5) 'land 'water)]
         [else s])))
   (indexes-array (array-shape tile-map))))

(: generate-map (-> Integer Integer Integer (Array Symbol)))
(define (generate-map land-mass size iter)
  (let ([tm : (Array Symbol) (initialize (tile-map size) land-mass)])
    (for ([i iter])
      (set! tm (one-step tm)))
    tm))



