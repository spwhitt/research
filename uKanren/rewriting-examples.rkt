#lang racket

(require "rewriting.rkt")

;; Propcalc

(vars A B C D X Y Z)

(defrule impl-elim `(=> ,X ,Y) `(or (not ,X) ,Y))
(defrule eq-elim `(= ,X ,Y) `(and (=> ,X ,Y) (=> ,Y ,X)))
(defrule not-not `(not (not ,X)) X)
(defrule demorgan1 `(not (and ,X ,Y)) `(or (not ,X) (not ,Y)))
(defrule demorgan2  `(not (or ,X ,Y)) `(and (not ,X) (not ,Y)))
(defrule and-or-dist `(and (or ,X ,Y) ,Z) `(or (and ,X ,Z) (and ,Y ,Z)))

(define testTerm '(and (=> r (and p q)) p))
; ((all (try impl-elim)) testTerm)
; ((compose id id) testTerm)
; ((bottomup id) testTerm)
; ((topdown id) testTerm)
