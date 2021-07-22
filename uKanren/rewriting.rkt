#lang racket

(require "lib.rkt")

;; Lets create a rewriting system
;; First lets see what terms might look like

(define math-term
  '(+ 5 (+ 10 2)))

(define joy-term
  '(dup *))

(define logic-term
  '(and (= a b) (!= a c)))

;; We can use variables from lib
(vars A B C D)

;; A rule is just a pair
(define +-commutative
  `(rule (+ ,A ,B) (+ ,B ,A)))

(define +-assoc
  `(rule (+ ,A (+ ,B ,C)) (+ (+ ,A ,B) ,C)))

;; We apply it left to right
(define (apply-rule rule term)
  (define pattern (cadr rule))
  (define template (cddr rule))
  (define substitution (unify pattern term '()))
  (apply-substitution substitution template))

;; EXAMPLES
(module+ test
  (require rackunit)

  (check-equal? (apply-rule +-commutative math-term) '((+ (+ 10 2) 5)))
  (check-equal? (apply-rule +-assoc math-term)  '((+ (+ 5 10) 2))))
