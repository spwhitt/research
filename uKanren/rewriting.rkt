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
(define +-comm
  `(rule (+ ,A ,B) (+ ,B ,A)))

(define +-assoc
  `(rule (+ ,A (+ ,B ,C)) (+ (+ ,A ,B) ,C)))

;; We apply it left to right
;; '() indicates failure to match
;; (term) indicates success, term was the result of the match
(define (apply-rule rule term)
  (match-define `(rule ,p1 ,p2) rule)
  (define substitution (unify p1 term '()))
  (if substitution
    (list (apply-substitution substitution p2))
    '()
    ))

;; Maybe we want to apply a rule right to left?
(define (flip rule)
  (match-define `(rule ,p1 ,p2) rule)
  `(rule ,p2 ,p1))

;; EXAMPLES
(module+ test
  (require rackunit)

  (check-equal? (apply-rule +-comm math-term) '((+ (+ 10 2) 5)))
  (check-equal? (apply-rule +-assoc math-term)  '((+ (+ 5 10) 2)))
  (check-equal? (apply-rule (flip +-assoc) '(+ (+ 5 10) 2)) '((+ 5 (+ 10 2))))
  (check-equal? (apply-rule +-assoc '(* 3 (* 4 5))) '())
  )

;; It might be convenient to bake application direcly into the rule
(define-syntax-rule (defrule name p1 p2)
  (define (name term) (apply-rule `(rule ,p1 ,p2) term)))

(defrule +-comm-f `(+ ,A ,B) `(+ ,B ,A))
(defrule +-assoc-f `(+ ,A (+ ,B ,C)) `(+ (+ ,A ,B) ,C))

(module+ test
  (check-equal? (+-comm-f math-term) '((+ (+ 10 2) 5)))
  (check-equal? (+-assoc-f math-term)  '((+ (+ 5 10) 2)))
  ;; But now we can't flip the rules
  ;; (check-equal? ((flip +-assoc-f) '(+ (+ 5 10) 2)) '((+ 5 (+ 10 2))))
  (check-equal? (+-assoc-f '(* 3 (* 4 5))) '())
  )

;; Maybe we don't even need to roll our own unification
;; We could use Racket's built-in match
;; Using my own implementation still appeals to me more
;;  1. I have control over it and can extend the matching algorithm
;;  2. I learn more by doing it myself
(define-syntax-rule (mrule name p1 p2)
  (define (name term)
    (match term
      [p1 (list p2)]
      [else (list)])))

(mrule +-comm-m `(+ ,a ,b) `(+ ,b ,a))
(mrule +-assoc-m `(+ ,a (+ ,b ,c)) `(+ (+ ,a ,b) ,c))

(module+ test
  (check-equal? (+-comm-m math-term) '((+ (+ 10 2) 5)))
  (check-equal? (+-assoc-m math-term)  '((+ (+ 5 10) 2)))
  (check-equal? (+-assoc-m '(* 3 (* 4 5))) '())
  )
