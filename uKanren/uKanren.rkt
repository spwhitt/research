#lang racket

;; Fail and succeed goals
(define fail '())
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

;; Generate a substitution which equates left with right in context subs.
;; Pairs and variables are treated as special.
;; Everything else is treated as an atom.
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
