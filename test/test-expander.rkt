#lang racket

(require rackunit rackunit/text-ui)
(require "../expander.rkt")
(require/expose "../expander.rkt" (gs-block-data gs-block-data-repr type-priority-list))

;; We consider blocks equal if they have the same repr.
(define-check (check-block-equal? block1 block2)
  (let ([repr1 (gs-block-data-repr block1)]
        [repr2 (gs-block-data-repr block2)])
    (with-check-info
        (('actual repr1)
         ('expected repr2))
      (unless (equal? repr1 repr2)
        (fail-check)))))

;; When creating gs-block-data values, for testing we need a lambda, but we do
;; not care what its value is because we cannot check equality of lambda values
;; anyway.
(define empty-lambda (λ () (void)))

(define (test-block repr) (gs-block-data empty-lambda repr))

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
   (check-equal? (gs-type (test-block "{1}")) 'block)
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
   (check-block-equal? (gs-convert-integer 'block 1) (test-block "{1}"))
   ))

(define test-gs-convert-array
  (test-suite
   "Test gs-convert-array"
   ; Integers inside arrays are treated as ascii character codes.
   (check-equal? (gs-convert-array 'string '(50)) "2")
   (check-equal? (gs-convert-array 'string '(50(51)52)) "234")
   (check-equal?
    (gs-convert-array 'string
                      `(50
                        ,(test-block "{51 a}")
                        52))
                      "251 a4")
   (check-block-equal? (gs-convert-array 'block '(50 "a"))
                       (test-block "{50 a}"))
   (check-block-equal?
    (gs-convert-array 'block `(50
                               ,(test-block "{51 a}")
                               "a"))
    (test-block "{50 {51 a} a}"))
   ;; Note the string integer to ascii in the nested list.
   (check-block-equal?
    (gs-convert-array 'block `(50
                               (51 52 "b")
                               "a"))
    (test-block "{50 34b a}"))
   ))

(define test-gs-convert-string
  (test-suite
   "Test gs-convert-string"
   (check-equal? (gs-convert-string 'string "50")
                 "50")
   (check-block-equal? (gs-convert-string 'block "50 \"a\"")
                       (test-block "{50 \"a\"}"))
   (check-block-equal?
    (gs-convert-string 'block "50 {51 a} \"a\"")
    (test-block "{50 {51 a} \"a\"}"))
   (check-block-equal?
   (gs-convert-string 'block "asdf")
    (test-block "{asdf}"))
   ))

(define test-gs-promote
  (test-suite
   "Test gs-promote"
   (let-values ([(arg1 arg2) (gs-promote 1 '(2))])
     (check-equal? arg1 '(1))
     (check-equal? arg2 '(2)))
   
   (let-values ([(arg1 arg2) (gs-promote 1 "2")])
     (check-equal? arg1 "1")
     (check-equal? arg2 "2"))
   
   (test-begin
    "integer and block"
    (define right-block (test-block "{2}"))
    (define-values (block1 block2) (gs-promote 1 right-block))
    (check-block-equal? block1 (test-block "{1}"))
    (check-block-equal? block2 right-block))

     
   (let-values ([(arg1 arg2) (gs-promote '(50) "3")])
     ; 50 is ascii code for 2.
     (check-equal? arg1 "2")
     (check-equal? arg2 "3"))
   
   (test-begin
    "integer-array and block"
    (define right-block (test-block "{3}"))
    (define-values (block1 block2) (gs-promote '(50 "a") right-block))
    (check-block-equal? block1 (test-block "{50 a}"))
    (check-block-equal? block2 right-block))
   
   (test-begin
    "string and block"
    (define right-block (test-block "{1234}"))
    (define-values (block1 block2) (gs-promote "asdf" right-block))
    (check-block-equal? block1 (test-block "{asdf}"))
    (check-block-equal? block2 right-block))
   ))

(define test-expander
  (test-suite
   "Test ../expander.rkt"
   test-gs-type
   test-gs-type-max
   test-gs-convert-integer
   test-gs-convert-array
   test-gs-convert-string
   test-gs-promote
   ))

(run-tests test-expander)
