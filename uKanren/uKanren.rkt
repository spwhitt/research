#lang racket
(require "lib.rkt")
(provide == any any* all* fresh vars run)

;;; GOALS
;;; All goals must return a closure of type (substitution -> substitution list)

;; Fail and succeed goals
;; Empty list indicates no valid substitutions - eg failure
(define fail (lambda (_) '()))
(define succeed (lambda (s) (list s)))

;; Execute goal and display cleaned-up values for variable v
(define (run v goal)
  ;; Kick off execution
  (define subs (goal empty-s))

  ;; Reify the variables for output
  ;; Use existing variable names, disambiguated with a number (Coq style)

  ;; List possible values for v
  ;; Substitute all variables in those terms for their final values
  (for/list ([s subs]) (apply-substitution s v))
  )

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

;; Make any lazy so that we can avoid executing branches
;; otherwise any recursive code will not terminate
(define-syntax-rule (any g ...)
  (any* (lambda (s) (g s)) ...))

(module+ test
  ;; 'fail' from rackunit conflicts with my fail defined above
  (require (except-in rackunit fail))

  ;; I have decided to use the capital letter convention for variables
  (vars A B C D)
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
  (check-equal? ((all* (== A 'a) (== A 'b)) empty-s) '())
  (check-equal? ((all* (== A B) (== B C) (== 'a 'b)) empty-s) '()))
