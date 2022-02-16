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
  (define map-size (make-parameter 40))
  (define land-mass (make-parameter 53))
  (define mountain-mass (make-parameter 35))
  (define beach-mass (make-parameter 80))
  (define iterations (make-parameter 10))

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
      [("-s" "--map-size") MAP-SIZE
                            "size of the map in (hex) tiles"
                            (map-size (string->number MAP-SIZE))]
      [("-l" "--land-mass") LAND-MASS
                            "probability for land tiles to appear"
                            (land-mass (string->number LAND-MASS))]
      [("-m" "--mountain-mass") MOUNTAIN-MASS
                            "probability for mountain tiles to appear"
                            (mountain-mass (string->number MOUNTAIN-MASS))]
      [("-m" "--beach-mass") BEACH-MASS
                            "probability for beach tiles to appear"
                            (beach-mass (string->number BEACH-MASS))]
      [("-i" "--iterations") ITERATIONS
                             "number of iterations of the cellular automata to perform"
                             (iterations (string->number ITERATIONS))]

      #:args () (void)))

  (new gui%
       [screen-width (screen-width)]
       [screen-height (screen-height)]
       [map-size (map-size)]
       [land-mass (land-mass)]
       [mountain-mass (mountain-mass)]
       [beach-mass (beach-mass)]
       [iterations (iterations)])
  )
