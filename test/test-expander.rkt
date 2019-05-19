#lang racket

(require rackunit rackunit/text-ui)
(require "../expander.rkt")
(require/expose "../expander.rkt" (gs-block-data gs-block-data-repr type-priority-list))

;; We consider blocks equal if they have the same repr.
(define (check-block-equal? block1 block2)
  (check-equal? (gs-block-data-repr block1)
                (gs-block-data-repr block2)))

;; When creating gs-block-data values, for testing we need a lambda, but we do
;; not care what its value is because we cannot check equality of lambda values
;; anyway.
(define empty-lambda (λ () (void)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Type prority (low -> high)
; integer -> array -> string -> block
; The type function tests are based on coercion behavior illustrated by the
; following examples using the + operator.
;  1[2]+ -> [1 2]
;  1'2'+ -> "12"
;  1{2}+ -> {1 2}
;  [50]'3'+ -> "23"
;  [50 'a']{3}+ -> {50 a 3}
;  'asdf'{1234}+ -> {asdf 1234}
(define test-gs-type
  (test-suite
   "Test gs-type"
   (check-equal? (gs-type 1) 'integer)
   (check-equal? (gs-type '(1)) 'array)
   (check-equal? (gs-type "1") 'string)
   (check-equal? (gs-type (gs-block-data empty-lambda "{1}")) 'block)
   ))

(define test-gs-type-max
  (test-suite
   "Test gs-type-max"
   (for* ([type-low type-priority-list]
          [type-high
           (drop type-priority-list (index-of type-priority-list type-low))])
      (check-equal? (gs-type-max type-low type-high) type-high))
   ))

(define test-gs-convert-integer
  (test-suite
   "Test gs-convert-integer"
   (check-equal? (gs-convert-integer 'array 1) '(1))   
   (check-equal? (gs-convert-integer 'string 1) "1")   
   (check-block-equal? (gs-convert-integer 'block 1) (gs-block-data empty-lambda "{1}"))
   ))

(define test-gs-promote
  (test-suite
   "Test gs-promote"
   (check-equal?
    (gs-promote 1 '(2))
    (values '(1) '(2)))
   
   (check-equal?
    (gs-promote 1 "2")
    (values "1" "2"))
   
   (test-begin
    "integer and block"
    (define right-block (gs-block-data empty-lambda "{2}"))
    (define-values (block1 block2) (gs-promote 1 right-block))
    (check-block-equal? block1 (gs-block-data empty-lambda "{1}"))
    (check-block-equal? block2 right-block))
   
   (check-equal?
    ; 50 is ascii code for 2.
    (gs-promote '(50) "3")
    (values "2" "3"))
   
   (test-begin
    "integer-array and block"
    (define right-block (gs-block-data empty-lambda "{3}"))
    (define-values (block1 block2) (gs-promote '(50) right-block))
    (check-block-equal? block1 (gs-block-data empty-lambda "{50 a}"))
    (check-block-equal? block2 right-block))
   
   (test-begin
    "string and block"
    (define right-block (gs-block-data empty-lambda "{1234}"))
    (define-values (block1 block2) (gs-promote "asdf" right-block))
    (check-block-equal? block1 (gs-block-data empty-lambda "{asdf}"))
    (check-block-equal? block2 right-block))
   ))

(define test-expander
  (test-suite
   "Test ../expander.rkt"
   test-gs-type
   test-gs-type-max
   test-gs-convert-integer
   ;test-gs-promote
   ))

(run-tests test-expander)
