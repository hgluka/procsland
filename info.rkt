#lang info
(define collection "procsland")
(define deps '("base"))
(define build-deps '("scribble-lib" "racket-doc" "rackunit-lib"))
(define scribblings '(("scribblings/racket-game.scrbl" ())))
(define pkg-desc "A cellular automata based procedural generation of islands.")
(define version "1.0.1")
(define pkg-authors '(lkh))
