#lang typed/racket
(require math/array)

(provide generate-map (struct-out tile) Tile)

(struct tile
        ([type : Symbol]
         [sheet-x : Integer]
         [sheet-y : Integer]
         [draw-under : Boolean]
         [name : String])
        #:type-name Tile)

(: land (-> Tile))
(define (land)
  (tile 'land 0 0 #f ""))

(: water (-> Tile))
(define (water)
  (tile 'water 3 1 #f ""))

(: beach (-> Tile))
(define (beach)
  (tile 'beach 3 3 #f ""))

(: mountain (-> Tile))
(define (mountain)
  (tile 'mountain (+ 0 (random 2)) (+ 1 (random 2)) #t ""))

(: forest (-> Tile))
(define (forest)
  (tile 'forest (+ 1 (random 2)) 0 #t ""))

(: farm (-> Tile))
(define (farm)
  (tile 'farm 2 3 #t ""))

(: city (-> String Tile))
(define (city name)
  (tile 'city (random 2) 3 #t name))

(: city-name-list (Listof String))
(define city-name-list
  (file->lines "resources/city-names.txt"))

(: city-name (-> String))
(define (city-name)
  (list-ref city-name-list (random (length city-name-list))))

(: tile-map (-> Integer Integer (Array Tile)))
(define (tile-map m n)
  (make-array (vector m n) (water)))

(: init-land-and-water (-> (Array Tile) Integer (Array Tile)))
(define (init-land-and-water tile-map land-mass)
  (array-map
   (λ: ([x : Tile])
     (if (< (random 100) land-mass)
         (land)
         x))
   tile-map))

(: init-mountains (-> (Array Tile) Integer (Array Tile)))
(define (init-mountains tile-map mountain-mass)
  (array-map
    (λ: ([x : Tile])
        (if (equal? (tile-type x) 'land)
          (if (< (random 100) mountain-mass)
            (mountain)
            x)
          x))
    tile-map))

(: init-forests (-> (Array Tile) Integer (Array Tile)))
(define (init-forests tile-map forest-mass)
  (array-map
    (λ: ([x : Tile])
        (if (equal? (tile-type x) 'land)
          (if (< (random 100) forest-mass)
            (forest)
            x)
          x))
    tile-map))

(: init-beaches (-> (Array Tile) Integer (Array Tile)))
(define (init-beaches tile-map beach-mass)
  (array-map
   (λ: ([js : (Vectorof Index)])
     (let ([s : Tile (array-ref tile-map js)])
       (cond
         [(and (equal? (tile-type s) 'water)
               (< (random 100) beach-mass)
               (> (count-tiles tile-map 'land (vector-ref js 0) (vector-ref js 1)) 0))
          (beach)]
         [else s])))
   (indexes-array (array-shape tile-map))))

(: init-cities (-> (Array Tile) Integer (Array Tile)))
(define (init-cities tile-map city-mass)
  (array-map
    (λ: ([x : Tile])
        (if (equal? (tile-type x) 'land)
          (if (< (random 100) city-mass)
            (city (city-name))
            x)
          x))
    tile-map))

(: count-tiles (-> (Array Tile) Symbol Integer Integer Integer))
(define (count-tiles tile-map tile x y)
  (array-count
   (λ: ([s : Tile])
     (equal? (tile-type s) tile))
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

(: land-step (-> (Array Tile) (Array Tile)))
(define (land-step tile-map)
  (array-map
   (λ: ([js : (Vectorof Index)])
     (let ([s : Tile (array-ref tile-map js)])
       (cond
         [(and (equal? (tile-type s) 'land)
               (< (count-tiles tile-map 'land (vector-ref js 0) (vector-ref js 1)) 2))
          (water)]
         [(and (equal? (tile-type s) 'land)
               (< (count-tiles tile-map 'land (vector-ref js 0) (vector-ref js 1)) 5))
          s]
         [(equal? (tile-type s) 'land) (water)]
         [(equal? (tile-type s) 'water) (if (< (count-tiles tile-map 'land (vector-ref js 0) (vector-ref js 1)) 5) (land) s)]
         [else s])))
   (indexes-array (array-shape tile-map))))

(: mountain-step (-> (Array Tile) (Array Tile)))
(define (mountain-step tile-map)
  (array-map
   (λ: ([js : (Vectorof Index)])
     (let ([s : Tile (array-ref tile-map js)])
       (cond
         [(and (equal? (tile-type s) 'mountain)
               (< (count-tiles tile-map 'mountain (vector-ref js 0) (vector-ref js 1)) 2))
          (land)]
         [(equal? (tile-type s) 'land) (if (> (count-tiles tile-map 'mountain (vector-ref js 0) (vector-ref js 1)) 4) (mountain) s)]
         [else s])))
   (indexes-array (array-shape tile-map))))

(: forest-step (-> (Array Tile) (Array Tile)))
(define (forest-step tile-map)
  (array-map
   (λ: ([js : (Vectorof Index)])
     (let ([s : Tile (array-ref tile-map js)])
       (cond
         [(and (equal? (tile-type s) 'forest)
               (< (count-tiles tile-map 'forest (vector-ref js 0) (vector-ref js 1)) 2))
          (land)]
         [(equal? (tile-type s) 'land) (if (> (count-tiles tile-map 'forest (vector-ref js 0) (vector-ref js 1)) 4) (forest) s)]
         [else s])))
   (indexes-array (array-shape tile-map))))

(: farm-step (-> (Array Tile) (Array Tile)))
(define (farm-step tile-map)
  (array-map
   (λ: ([js : (Vectorof Index)])
     (let ([s : Tile (array-ref tile-map js)])
       (cond
         [(and (equal? (tile-type s) 'farm)
               (< (count-tiles tile-map 'city (vector-ref js 0) (vector-ref js 1)) 1)
               (< (count-tiles tile-map 'farm (vector-ref js 0) (vector-ref js 1)) 3))
          (land)]
         [(and (equal? (tile-type s) 'land)
               (> (count-tiles tile-map 'city (vector-ref js 0) (vector-ref js 1)) 0))
          (farm)]
         [(equal? (tile-type s) 'land) (if (> (count-tiles tile-map 'farm (vector-ref js 0) (vector-ref js 1)) 6) (farm) s)]
         [else s])))
   (indexes-array (array-shape tile-map))))

(: generate-land (-> (Array Tile) Integer Integer (Array Tile)))
(define (generate-land tile-map land-mass iter)
  (let ([tm : (Array Tile) (init-land-and-water tile-map land-mass)])
    (for ([i iter])
      (set! tm (land-step tm)))
    tm))

(: generate-mountains (-> (Array Tile) Integer Integer (Array Tile)))
(define (generate-mountains tile-map mountain-mass iter)
  (let ([tm : (Array Tile) (init-mountains tile-map mountain-mass)])
    (for ([i iter])
      (set! tm (mountain-step tm)))
    tm))

(: generate-forests (-> (Array Tile) Integer Integer (Array Tile)))
(define (generate-forests tile-map forest-mass iter)
  (let ([tm : (Array Tile) (init-forests tile-map forest-mass)])
    (for ([i iter])
      (set! tm (forest-step tm)))
    tm))

(: generate-cities (-> (Array Tile) Integer Integer (Array Tile)))
(define (generate-cities tile-map city-mass iter)
  (let ([tm : (Array Tile) (init-cities tile-map city-mass)])
    (for ([i iter])
      (set! tm (farm-step tm)))
    tm))

(: generate-map (-> Integer Integer Integer Integer Integer Integer Integer Integer (Array Tile)))
(define (generate-map map-height map-width iter land-mass mountain-mass forest-mass beach-mass city-mass)
  (generate-cities (generate-forests (generate-mountains (init-beaches (generate-land (tile-map map-height map-width) land-mass iter) beach-mass) mountain-mass iter) forest-mass iter) city-mass iter))
