#lang racket

(require "uKanren.rkt")

(define (conso a b p) (== (cons a b) p))
(define (caro p a) (fresh (b) (conso a b p)))
(define (cdro p b) (fresh (a) (conso a b p)))

; These recursive implementations never terminate, because any* always
; executes both branches. We need to make any lazy.
(define (memo a l)
  (fresh (t)
    (any*
      (caro l a)
      (all* (cdro l t) (memo a t)))))

(define (appendo a b ab)
  (fresh (h t tb)
    (any*
      (all* (== a '()) (== b ab))
      (all* (conso h t a) (appendo t b tb) (appendo h tb ab)))))

; Some example calls
; ((conso 'a 'b A) empty-s)
; ((conso A 'b (cons 'a 'b)) empty-s)
; ((caro '(a b c d) A) empty-s)
; ((cdro (cons 'b 'c) A) empty-s)
; ((memo 'a '(a b c d)) empty-s)
