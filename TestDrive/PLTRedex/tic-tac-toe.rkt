#lang racket

(require redex)

;;; Inspired by:
;;; Leandro Facchinetti - Playing the Game with PLT Redex
;;; https://www.youtube.com/watch?v=NszLQNROdw0
;;;
;;; Implemented Tic-Tac-Toe instead of Peg Solitare

(define-term initial-board
  (turn x
        [[ - - - ]
         [ - - - ]
         [ - - - ]]))

(define-language tic-tac-toe
  [ board ::=
          (turn piece
                [[ position position position ]
                 [ position position position ]
                 [ position position position ]])]
  [position ::= piece - ]
  [piece ::= x o])

(define play
  (reduction-relation tic-tac-toe
                      #:domain board
                      #:codomain board
                      [--> (turn x [any_1 ... [ any_2 ... - any_3 ...] any_4 ...])
                           (turn o [any_1 ... [ any_2 ... x any_3 ...] any_4 ...])]
                      [--> (turn o [any_1 ... [ any_2 ... - any_3 ...] any_4 ...])
                           (turn x [any_1 ... [ any_2 ... o any_3 ...] any_4 ...])]))

#;(apply-reduction-relation play (term initial-board))

#;(traces play (term initial-board))

(stepper play (term initial-board))
