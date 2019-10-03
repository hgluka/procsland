#lang racket
(require
  racket/gui
  racket/draw)
(require "map.rkt")

(provide
 make-gui)

(define gui%
  (class object%
    (init-field screen-width
                screen-height)
    (define frame
      (new frame%
           [label "procsland"]
           [style '(no-resize-border)]))
    (define tm (generate-map 45 39 0 '()))
    (define (final-map iter fm)
      (if (= iter 16)
          (cellular-automaton convert-to-beach fm 45 39 0 '())
          (final-map (+ iter 1) (cellular-automaton cell-decide fm 45 39 0 '()))))
    (define fm (final-map 0 tm))
    (define canvas
      (new canvas%
           [parent frame]
           [min-width screen-width]
           [min-height screen-height]
           [paint-callback (draw-map fm 45 39)]))
    
    (send frame show #t)
    (super-new)))

(define (make-gui w h)
  (new gui%
       [screen-width w]
       [screen-height h]))
