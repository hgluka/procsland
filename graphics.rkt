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
    (define canvas
      (new canvas%
           [parent frame]
           [min-width screen-width]
           [min-height screen-height]))
    (send frame show #t)
    (super-new)))

(define (make-gui w h mw mh i)
  (new gui%
       [screen-width w]
       [screen-height h]
       [map-width mw]
       [map-height mh]
       [iterations i]))
