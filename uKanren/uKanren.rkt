#lang racket
(provide empty-s == any* all* fresh)

;; Variables
(define (var x)
  (cons '? x))

(define (var? x)
  (and (pair? x)
       (eq? (car x) '?)))

(define var= eq?)

(module+ test
  ;; 'fail' from rackunit conflicts with my fail defined below
  (require (only-in rackunit
    check-true check-false check-not-false
    check-eq? check-not-eq? check-equal?))

  ;; I have decided to use the capital letter convention for variables
  (define A (var 'A))
  (define B (var 'B))
  (define C (var 'C))
  (define D (var 'D))

  (check-true (var? A))
  (check-eq? A A)
  (check-not-eq? (var 'A) (var 'A)))

;; Variable Substitutions
;; Represented by an association list (list of pairs)
(define empty-s '())
(define (extend-s key value subs)
  `((,key . ,value) . ,subs))

;; Resolve a chain of substitutions for a variable
;; Maybe a union find structure would be efficient here?
(define (resolve var subs)
  (define val (assq var subs))
  (cond
    ((and val (var? var)) (resolve (cdr val) subs))
    (else var)))

(module+ test
  (define ex-s `((,A . ,B) (,B . ,C) (,C . v)))
  (check-equal? (resolve A ex-s) 'v)
  (check-equal? (resolve B ex-s) 'v)
  (check-equal? (resolve 'q ex-s) 'q)
  (check-equal? (resolve D ex-s) D))

;; Parameters:
;;   left, right: Expressions to unify
;;     Can contain variables, pairs, and atoms (everything else)
;;   subs: Variable substitution representing the current context
;; Returns:
;;   Success: Substitution unifying left and right
;;   Failure: #f
(define (unify left right subs)
  (define vl (resolve left subs))
  (define vr (resolve right subs))
  (cond 
    ((eq? vl vr) subs)
    ((var? vl) (extend-s vl vr subs))
    ((var? vr) (extend-s vr vl subs))
    ((and (pair? vl) (pair? vr))
     (define s1 (unify (car vl) (car vr) subs))
     (if s1 (unify (cdr vl) (cdr vr) s1) #f))
    (else #f)))

(module+ test
  (check-equal? (unify 'a 'a empty-s) empty-s)
  (check-false (unify 'a 'b empty-s))
  
  (check-equal? (unify A 'a empty-s) `((,A . a)))
  (check-false (unify A 'a `((,A . b))))

  (check-equal? (unify A A empty-s) empty-s)
  (check-equal? (unify A B empty-s) `((,A . ,B)))
  (check-false (unify A B `((,A . a) (,B . b))))

  (check-false (unify (cons A A) (cons 'a 'b) empty-s))
  (check-not-false (unify (cons A A) (cons 'a B) empty-s))

  (define subs (unify
                 (cons (cons A C) (cons A D))
                 (cons (cons B D) (cons D 'v))
                 empty-s))
  (check-equal? (resolve A subs) 'v)
  (check-equal? (resolve B subs) 'v)
  (check-equal? (resolve C subs) 'v))


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

;; A syntactical convenience for defining variables easier
(define-syntax-rule (fresh (v ...) expr)
  (let ((v (var 'v)) ...) expr))
