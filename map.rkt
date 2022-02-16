#lang typed/racket
(require math/array)

(provide generate-map)

(: tile-map (-> Integer (Array Symbol)))
(define (tile-map n)
  (make-array (vector n n) 'empty))

(: init-land-and-water (-> (Array Symbol) Integer (Array Symbol)))
(define (init-land-and-water tile-map land-mass)
  (array-map
   (λ: ([x : Symbol])
     (if (< (random 100) land-mass)
         'land
         'water))
   tile-map))

(: init-mountains (-> (Array Symbol) Integer (Array Symbol)))
(define (init-mountains tile-map mountain-mass)
  (array-map
    (λ: ([x : Symbol])
        (if (equal? x 'land)
          (if (< (random 100) mountain-mass)
            'mountain
            'land)
          'water))
    tile-map))

(: init-beaches (-> (Array Symbol) Integer (Array Symbol)))
(define (init-beaches tile-map beach-mass)
  (array-map
   (λ: ([js : (Vectorof Index)])
     (let ([s : Symbol (array-ref tile-map js)])
       (cond
         [(and (equal? s 'water)
               (< (random 100) beach-mass)
               (> (count-tiles tile-map 'land (vector-ref js 0) (vector-ref js 1)) 0))
          'beach]
         [else s])))
   (indexes-array (array-shape tile-map))))

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

(: land-step (-> (Array Symbol) (Array Symbol)))
(define (land-step tile-map)
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

(: mountain-step (-> (Array Symbol) (Array Symbol)))
(define (mountain-step tile-map)
  (array-map
   (λ: ([js : (Vectorof Index)])
     (let ([s : Symbol (array-ref tile-map js)])
       (cond
         [(and (equal? s 'mountain)
               (< (count-tiles tile-map 'mountain (vector-ref js 0) (vector-ref js 1)) 2))
          'land]
         [(equal? s 'land) (if (> (count-tiles tile-map 'mountain (vector-ref js 0) (vector-ref js 1)) 4) 'mountain 'land)]
         [else s])))
   (indexes-array (array-shape tile-map))))

(: generate-land (-> (Array Symbol) Integer Integer (Array Symbol)))
(define (generate-land tile-map land-mass iter)
  (let ([tm : (Array Symbol) (init-land-and-water tile-map land-mass)])
    (for ([i iter])
      (set! tm (land-step tm)))
    tm))

(: generate-mountains (-> (Array Symbol) Integer Integer (Array Symbol)))
(define (generate-mountains tile-map mountain-mass iter)
  (let ([tm : (Array Symbol) (init-mountains tile-map mountain-mass)])
    (for ([i iter])
      (set! tm (mountain-step tm)))
    tm))

(: generate-map (-> Integer Integer Integer Integer Integer (Array Symbol)))
(define (generate-map size iter land-mass mountain-mass beach-mass)
  (init-beaches (generate-mountains (generate-land (tile-map size) land-mass iter) mountain-mass iter) beach-mass))
