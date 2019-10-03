#lang racket
(require racket/draw)
(provide
 cell-decide
 convert-to-beach
 cellular-automaton
 generate-map
 draw-map)

(define alive-chance 64)

(define land-bitmap
  (read-bitmap "images/hex_grass_large.png" 'png/alpha))

(define water-bitmap
  (read-bitmap "images/hex_water_large.png" 'png/alpha))

(define beach-bitmap
  (read-bitmap "images/hex_beach_large.png" 'png/alpha))

(define hex-width
  (send land-bitmap get-width))

(define hex-height
  (send land-bitmap get-height))

(define (offset r)
  (if (zero? (remainder r 2))
      (cons 0 (quotient (* hex-height 3) 4))
      (cons (quotient hex-width 2) (quotient (* hex-height 3) 4))))

(define (get-tile-point w h row-num col-num)
  (cons
   (+ (car (offset row-num)) (* col-num hex-width))
   (* row-num (cdr (offset row-num)))))

(define (cell-decide neighbours cell)
  (define (count-water lst)
    (if (null? lst)
        0
        (+ (if (eq? (car lst) 'water) 1 0) (count-water (cdr lst)))))
  (cond
    [(eq? cell 'water) (case (count-water neighbours)
                        [(0 1) ''land]
                        [(2 3 4) ''water]
                        [(5 6) ''land])]
    [(eq? cell 'land) (if (< (count-water neighbours) 5) ''water ''land)]))

(define (convert-to-beach neighbours cell)
  (define (count-land lst)
    (if (null? lst)
        0
        (+ (if (eq? (car lst) 'land) 1 0) (count-land (cdr lst)))))
  (if (and (eq? cell 'land) (= (count-land neighbours) 6)) ''land (if (eq? cell 'water) ''water ''beach)))

(define (cellular-automaton cell-decider tile-list w h iter new-list)
  (if (> iter (- (* w h) 1))
      new-list
      (cellular-automaton cell-decider tile-list w h (+ iter 1) (cons
                                                    (cell-decider (get-neighbours tile-list w h (remainder iter w) (quotient iter w))
                                                                    (last (list-ref tile-list iter)))
                                                    new-list))))

(define (generate-map w h iter tile-list)
  (if (= iter (* w h))
      tile-list
      (generate-map w h (+ iter 1) (cons (let ([n (random 100)])
                                           (if (< n alive-chance) ''water ''land))
                                         tile-list))))

(define (get-neighbours tile-list w h q r)
  (define oddr-directions (list `(,'(1 0) ,'(0 -1) ,'(-1 -1) 
                                  ,'(-1 0) ,'(-1 1) ,'(0 1))
                                `(,'(1 0) ,'(1 -1) ,'(0 -1)
                                  ,'(-1 0) ,'(0 1) ,'(1 1))))
  (define (dir-to-neighbour dir)
    (if (or
        (>= (+ (+ q (car dir)) (* (+ r (last dir)) w)) (* w h))
        (< (+ (+ q (car dir)) (* (+ r (last dir)) w)) 0))
        'nothing
        (last (list-ref tile-list (+ (+ q (car dir)) (* (+ r (last dir)) w))))))
  (if (= (remainder r 2) 0)
      (map dir-to-neighbour (car oddr-directions))
      (map dir-to-neighbour (last oddr-directions))))
    
(define (draw-map tile-list map-width map-height)
  (lambda (canvas dc)
    (define (draw-land xy) (send dc draw-bitmap land-bitmap (car xy) (cdr xy)))
    (define (draw-water xy) (send dc draw-bitmap water-bitmap (car xy) (cdr xy)))
    (define (draw-beach xy) (send dc draw-bitmap beach-bitmap (car xy) (cdr xy)))
    
    (define (draw-tile tile-list mw mh row-num col-num)
      (case (last (list-ref tile-list (+ (* row-num mw) col-num)))
        ['land (draw-land (get-tile-point mw mh row-num col-num))]
        ['water (draw-water (get-tile-point mw mh row-num col-num))]
        ['beach (draw-beach (get-tile-point mw mh row-num col-num))]))

    (define (draw-row tl mw mh row-num)
      (for ([i mw])
        (draw-tile tl mw mh row-num i)))

    (for ([i map-height])
      (draw-row tile-list map-width map-height i))))
