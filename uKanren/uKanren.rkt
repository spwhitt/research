#lang racket
(require "lib.rkt")
(provide == any* all* fresh vars)

(module+ test
  ;; 'fail' from rackunit conflicts with my fail defined below
  (require (only-in rackunit
    check-true check-false check-not-false
    check-eq? check-not-eq? check-equal?))

  ;; I have decided to use the capital letter convention for variables
  (vars A B C D))

;;; GOALS
;;; All goals must return a closure of type (substitution -> substitution list)

;; Fail and succeed goals
;; Empty list indicates no valid substitutions - eg failure
(define fail (lambda (_) '()))
(define succeed (lambda (s) (list s)))

;; Unify turned into a goal
(define (== left right)
  (lambda (s)
    (define r (unify left right s))
    (if r (succeed r) (fail r))))

;; 'Any' goal - succeeds if any argument goal succeeds
(define (any* . g*)
  (lambda (s)
    ;; g* is a list of goals
    ;; Pass our substitution (s) to each one and append the results
    ;; Thus, if ANY goal generates a substitution, we will return a substitution
    (for/fold
      ([results '()])
      ([g g*])
      (append (g s) results))))

(module+ test
  (check-equal? ((any* (== 'a 'b) (== A A)) empty-s) '(()))
  (check-equal? ((any* fail fail) empty-s) (fail 'a))
  (check-true (set=?
                ((any* (== A 'a) (== A 'b)) empty-s)
                `(((,A . a)) ((,A . b))))))

;; 'All' goal - succeeds if all argument goals succeed
(define (all* . g*)
  (lambda (s)
    (for/fold
      ([results (list s)])
      ([g g*])
      (apply append (map g results)))))

(module+ test
  (check-equal? ((all* (== A 'a) (== A 'b)) empty-s) '()))
