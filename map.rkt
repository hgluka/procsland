#lang typed/racket
(require math/array)

(define alive-chance 64)

(: tile-map (Array Symbol))
(define tile-map
  (make-array #(16 16) 'empty))

(: initialize (-> (Array Symbol) (Array Symbol)))
(define (initialize tile-map)
  (array-map
   (λ: ([x : Symbol])
     (if (< (random 100) alive-chance)
         'land
         'water))
   tile-map))

(: count-tiles (-> (Array Symbol) Symbol Integer Integer Integer))
(define (count-tiles tile-map tile x y)
  (array-count
   (λ: ([s : Symbol])
     (equal? s tile))
   (array-indexes-ref
    tile-map
    (array #[(vector (min (+ x 1) 15) y)
             (vector x (min (+ y 1) 15))
             (vector (max (- x 1) 0) y)
             (vector x (max (- y 1) 0))
             (vector (min (+ x 1) 15) (min (+ y 1) 15))
             (vector (max (- x 1) 0) (max (- y 1) 0))
             (vector (max (- x 1) 0) (min (+ y 1) 15))
             (vector (min (+ x 1) 15) (max (- y 1) 0))]))))
     
  
(: one-step (-> (Array Symbol) (Array Symbol)))
(define (one-step tile-map)
  (array-map
   (λ: ([js : (Vectorof Index)])
     (let ([s : Symbol (array-ref tile-map js)])
       (cond
         [(and (equal? s 'land)
               (> (count-tiles tile-map 'land (vector-ref js 0) (vector-ref js 1)) 5))
          'water]
         [else s])))
   (indexes-array (array-shape tile-map))))

