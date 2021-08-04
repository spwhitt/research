#lang racket

(require "lib.rkt")

(provide vars defrule innermost choice bottomup try all id topdown)

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

;;; Strategies

;; Leaves term unchanged
(define (id t) (list t))
;; Alternate definition as a rule:
;; (defrule idr A A)

;; Always fails
(define (fail t) (list))

;; Apply strategies consecutively left-to-right
(define (compose . strategies)
  (lambda (x)
    (for/fold
      ([results (list x)])
      ([s strategies])
      #:break (empty? results) 
      (append-map s results))))

;; Try s1. If it fails, use s2...
(define (choice . choices )
  (define (helper choices x)
    (cond
      ((empty? choices) (fail x))
      (else
        (define s (car choices))
        (define r (s x))
        (if (empty? r) (helper (cdr choices) x) r)
        )))
  (lambda (x) (helper choices x)))

;; Apply s to all the direct subterms of a term
;; TODO: append mashes failure '() together with success '(TERM), causing
;; failures to vanish. This is probably not desirable behavior
(define (all s)
  (lambda (t)
    (cond
      ((list? t) (append-map s t))
      (else (fail t)))))

;; Visits subterms left-to-right, only modifies the first that succeeds
(define (one s) #f)

;; Attempts s but does nothing if it fails
(define (try s)
  (choice s id))

;;; Recursive calls need to be eta-expanded with this lambda (t) wrapper
;;; because racket is not lazy. There is surely a better way to do this
;;; will tackle that later.

;; Repeatedly apply s to a term
(define (repeat s)
  (try (compose s (lambda (t) ((repeat s) t)))))

;; Apply s to entire term, starting at top
;; Preorder Traversal?
(define (topdown s)
  (compose s (all (lambda (t) ((topdown s) t)))))

;; Apply s to entire term, starting at bottom
;; Postorder Traversal
(define (bottomup s)
  (compose (all (lambda (t) ((bottomup s) t))) s))

;; Apply s to the entire term, first on the way down, then on the way up
(define (downup s)
  (compose s (lambda (t) ((downup s) t)) s))

;; post-order traversal
(define (innermost s)
  (bottomup (try (compose s (lambda (t) ((innermost s) t))))))

(define (oncetd s)
  (choice s (one (lambda (t) ((oncetd s) t)))))

(define (alltd s)
  (choice s (all (lambda (t) ((alltd s) t)))))

(module+ test
  ;; Peano rules
  (defrule plus-0 `(+ z ,A) A)
  (defrule plus-n `(+ (s ,A) ,B) `(+ ,A (s ,B)))

  (define one '(s z))
  (define two '(s (s z)))
  (define three '(s (s (s z))))
  (define four '(s (s (s (s z)))))

  (define plus-onestep (choice plus-0 plus-n))

  (check-equal? (plus-onestep `(+ z ,three)) (id three))
  (check-equal? (plus-onestep `(+ ,three ,one)) (id `(+ ,two ,two)))

  (check-equal? ((repeat plus-onestep) `(+ ,three ,one)) (id  four)))
