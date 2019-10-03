#lang racket

(module+ test
  (require rackunit))

(module+ test
  ;; Tests to be run with raco test
  )

(module+ main
  (require "graphics.rkt")
  (make-gui 640 400)
  ;; Main entry point, executed when run with the `racket` executable or DrRacket.
  )
