#lang racket
(require
  racket/gui
  racket/draw)
(require "map.rkt")

(provide
 make-gui)

(define land-bitmap
  (read-bitmap "images/hex_grass_large.png" 'png/alpha))

(define mountain-bitmap
  (read-bitmap "images/hex_mountain_large.png" 'png/alpha))

(define water-bitmap
  (read-bitmap "images/hex_water_large.png" 'png/alpha))

(define beach-bitmap
  (read-bitmap "images/hex_beach_large.png" 'png/alpha))

(struct point ([x : Integer] [y : Integer]))

(define hex-width
  (send land-bitmap get-width))

(define hex-height
  (send land-bitmap get-height))

(define gui%
  (class object%
    (init-field screen-width
                screen-height
                map-width
                map-height
                iterations)
    (define frame
      (new frame%
           [label "procsland"]
           [style '(no-resize-border)]))
    (define tm (generate-map map-width map-height 0 '()))
    (define (final-map iter fm)
      (if (= iter iterations)
          (automaton beachify fm map-width map-height 0 '())
          (final-map (+ iter 1) (automaton turn fm map-width map-height 0 '()))))
    (define fm (final-map 0 tm))
    (define canvas
      (new canvas%
           [parent frame]
           [min-width screen-width]
           [min-height screen-height]
           [paint-callback (draw-map fm map-width map-height)]))
    
    (send frame show #t)
    (super-new)))

(define (make-gui w h mw mh i)
  (new gui%
       [screen-width w]
       [screen-height h]
       [map-width mw]
       [map-height mh]
       [iterations i]))
