#lang racket

(require "uKanren.rkt")

(define (conso a b p) (== (cons a b) p))
(define (caro p a) (fresh (b) (conso a b p)))
(define (cdro p b) (fresh (a) (conso a b p)))

(define (memo a l)
  (fresh (t)
    (any
      (caro l a)
      (all* (cdro l t) (memo a t)))))

(define (appendo a b ab)
  (fresh (h t tb)
    (any
      (all* (== a '()) (== b ab))
      (all* (conso h t a) (conso h tb ab) (appendo t b tb)))))

(module+ test
  (require rackunit)

  (define-binary-check (check-set=? set=? actual expected))

  (vars A B C D)
  (check-equal? (run A (conso A  'a (cons 'a 'a))) '(a))
  (check-equal? (run A (conso A  B (cons B 'a))) '(a))
  (check-equal? (run A (all* (== A (cons B C)) (== B 'b) (== C 'c))) '((b . c)))


  (define empty-s '())
  (check-equal? (run A (conso 'a 'b A)) '((a . b)))
  (check-equal? (run A (conso A 'b (cons 'a 'b))) '(a))

  (check-equal? (run A (caro '(a b c d) A)) '(a))
  (check-equal? (run A (cdro (cons 'b 'c) A)) '(c))

  (check-equal? (run '() (memo 'a '(a b c d))) '(()))
  (check-set=? (run A (memo A '(a b c d))) '(a b c d))

  (check-equal? (run A (appendo '(a b c) '(d e f) A)) '((a b c d e f)))
  (check-equal? (run A (appendo A '(d e f) '(a b c d e f))) '((a b c)))
  (check-equal? (run A (appendo '(a b c) A '(a b c d e f))) '((d e f)))
  
  ;; Self Reference
  ;; (run A (conso A A A))
  ;; (check-equal? (run A (appendo A '(d e f) A)) '((a b c)))
