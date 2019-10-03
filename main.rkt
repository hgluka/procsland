#!/usr/bin/env racket
#lang racket

(module+ test
  (require rackunit))

(module+ test
  ;; Tests to be run with raco test
  )

(module+ main
  (require "graphics.rkt")

  ; command line args
  (define screen-width (make-parameter 1600))
  (define screen-height (make-parameter 900))
  (define map-width (make-parameter 45))
  (define map-height (make-parameter 39))
  (define iterations (make-parameter 16))

  (define parser
    (command-line
      #:usage-help
      "procsland is an hex map island generator"
      "based on cellular automata."

      #:once-each
      [("-W" "--screen-width") SCREEN-WIDTH
                               "width of the screen in pixels"
                               (screen-width (string->number SCREEN-WIDTH))]
      [("-H" "--screen-height") SCREEN-HEIGHT
                                "height of the screen in pixels"
                                (screen-height (string->number SCREEN-HEIGHT))]
      [("-x" "--map-width") MAP-WIDTH
                            "width of the map in (hex) tiles"
                            (map-width (string->number MAP-WIDTH))]
      [("-y" "--map-height") MAP-HEIGHT 
                             "height of the map in (hex) tiles"
                             (map-height (string->number MAP-HEIGHT))]
      [("-i" "--iterations") ITERATIONS 
                             "number of iterations of the cellular automata to perform"
                             (iterations (string->number ITERATIONS))]

      #:args () (void)))

  (make-gui 
    (screen-width)
    (screen-height)
    (map-width)
    (map-height)
    (iterations))
  )
