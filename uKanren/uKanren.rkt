#lang racket

;; Fail and succeed goals
(define (fail) '())
(define (succeed x) (list x))

;; Variables
(define (var x)
  (cons '? x))

(define (var? x)
  (and (pair? x)
       (eq? (car x) '?)))

(module+ test
  (require rackunit)

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
(define (empty-s) '())
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

;; Generate a substitution which equates x with y, in context s
(define (unify x y s) #f)

(module+ test
  (check-equal? (unify 'a 'a empty-s) empty-s)
  (check-false (unify 'a 'b empty-s))
  (check-equal? (unify A A empty-s) empty-s)
  (check-equal? (unify A B empty-s) `((,A ,B)))
  (check-false (unify (cons A A) (cons 'a 'b) empty-s))
  (check-not-false (unify (cons A A) (cons 'a B) empty-s))
  )
