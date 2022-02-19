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
  (define screen-width (make-parameter 1366))
  (define screen-height (make-parameter 768))
  (define map-height (make-parameter 34))
  (define map-width (make-parameter 38))
  (define land-mass (make-parameter 53))
  (define mountain-mass (make-parameter 35))
  (define forest-mass (make-parameter 45))
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
      [("-e" "--map-height") MAP-HEIGHT
                            "height of the map in (hex) tiles"
                            (map-height (string->number MAP-HEIGHT))]
      [("-w" "--map-width") MAP-WIDTH
                            "width of the map in (hex) tiles"
                            (map-width (string->number MAP-WIDTH))]
      [("-l" "--land-mass") LAND-MASS
                            "probability for land tiles to appear"
                            (land-mass (string->number LAND-MASS))]
      [("-m" "--mountain-mass") MOUNTAIN-MASS
                            "probability for mountain tiles to appear"
                            (mountain-mass (string->number MOUNTAIN-MASS))]
      [("-f" "--forest-mass") FOREST-MASS
                            "probability for forest tiles to appear"
                            (forest-mass (string->number FOREST-MASS))]
      [("-b" "--beach-mass") BEACH-MASS
                            "probability for beach tiles to appear"
                            (beach-mass (string->number BEACH-MASS))]
      [("-i" "--iterations") ITERATIONS
                             "number of iterations of the cellular automata to perform"
                             (iterations (string->number ITERATIONS))]

      #:args () (void)))

  (new gui%
       [screen-width (screen-width)]
       [screen-height (screen-height)]
       [map-height (map-height)]
       [map-width (map-width)]
       [land-mass (land-mass)]
       [mountain-mass (mountain-mass)]
       [forest-mass (forest-mass)]
       [beach-mass (beach-mass)]
       [iterations (iterations)])
  )
