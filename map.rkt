#lang typed/racket
(require math/array)

(provide generate-map)

(: tile-map (-> Integer Integer (Array Symbol)))
(define (tile-map m n)
  (make-array (vector m n) 'empty))

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
          x))
    tile-map))

(: init-forests (-> (Array Symbol) Integer (Array Symbol)))
(define (init-forests tile-map forest-mass)
  (array-map
    (λ: ([x : Symbol])
        (if (equal? x 'land)
          (if (< (random 100) forest-mass)
            'forest
            'land)
          x))
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

(: init-cities (-> (Array Symbol) Integer (Array Symbol)))
(define (init-cities tile-map city-mass)
  (array-map
    (λ: ([x : Symbol])
        (if (equal? x 'land)
          (if (< (random 100) city-mass)
            'city
            'land)
          x))
    tile-map))

(: count-tiles (-> (Array Symbol) Symbol Integer Integer Integer))
(define (count-tiles tile-map tile x y)
  (array-count
   (λ: ([s : Symbol])
     (equal? s tile))
   (let ([h : Integer (- (vector-ref (array-shape tile-map) 1) 1)]
         [w : Integer (- (vector-ref (array-shape tile-map) 0) 1)])
     (array-indexes-ref
      tile-map
      (array #[(vector (min (+ x 1) w) y)
               (vector x (min (+ y 1) h))
               (vector (max (- x 1) 0) y)
               (vector x (max (- y 1) 0))
               (vector (min (+ x 1) w) (min (+ y 1) h))
               (vector (max (- x 1) 0) (max (- y 1) 0))
               (vector (max (- x 1) 0) (min (+ y 1) h))
               (vector (min (+ x 1) w) (max (- y 1) 0))])))))

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

(: forest-step (-> (Array Symbol) (Array Symbol)))
(define (forest-step tile-map)
  (array-map
   (λ: ([js : (Vectorof Index)])
     (let ([s : Symbol (array-ref tile-map js)])
       (cond
         [(and (equal? s 'forest)
               (< (count-tiles tile-map 'forest (vector-ref js 0) (vector-ref js 1)) 2))
          'land]
         [(equal? s 'land) (if (> (count-tiles tile-map 'forest (vector-ref js 0) (vector-ref js 1)) 4) 'forest 'land)]
         [else s])))
   (indexes-array (array-shape tile-map))))

(: farm-step (-> (Array Symbol) (Array Symbol)))
(define (farm-step tile-map)
  (array-map
   (λ: ([js : (Vectorof Index)])
     (let ([s : Symbol (array-ref tile-map js)])
       (cond
         [(and (equal? s 'farm)
               (< (count-tiles tile-map 'city (vector-ref js 0) (vector-ref js 1)) 1)
               (< (count-tiles tile-map 'farm (vector-ref js 0) (vector-ref js 1)) 3))
          'land]
         [(and (equal? s 'land)
               (> (count-tiles tile-map 'city (vector-ref js 0) (vector-ref js 1)) 0))
          'farm]
         [(equal? s 'land) (if (> (count-tiles tile-map 'farm (vector-ref js 0) (vector-ref js 1)) 6) 'farm 'land)]
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

(: generate-forests (-> (Array Symbol) Integer Integer (Array Symbol)))
(define (generate-forests tile-map forest-mass iter)
  (let ([tm : (Array Symbol) (init-forests tile-map forest-mass)])
    (for ([i iter])
      (set! tm (forest-step tm)))
    tm))

(: generate-cities (-> (Array Symbol) Integer Integer (Array Symbol)))
(define (generate-cities tile-map city-mass iter)
  (let ([tm : (Array Symbol) (init-cities tile-map city-mass)])
    (for ([i iter])
      (set! tm (farm-step tm)))
    tm))

(: generate-map (-> Integer Integer Integer Integer Integer Integer Integer Integer (Array Symbol)))
(define (generate-map map-height map-width iter land-mass mountain-mass forest-mass beach-mass city-mass)
  (generate-cities (generate-forests (generate-mountains (init-beaches (generate-land (tile-map map-height map-width) land-mass iter) beach-mass) mountain-mass iter) forest-mass iter) city-mass iter))
