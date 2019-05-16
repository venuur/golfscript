#lang br
(require "../lexer.rkt" brag/support rackunit rackunit/text-ui)

(define (lex str) (apply-port-proc basic-lexer str))

(define (test-srcloc-token sym str n [m 1] [L 1] [p (add1 n)] #:skip? [skip #f])
  (srcloc-token (token sym str #:skip? skip) (srcloc 'string m n p L)))
(define (space n [m 1]) (test-srcloc-token 'SYMBOL '| | n m))
(define (newline n [m 1]) (test-srcloc-token 'NEWLINE "\n" n m #:skip? #t))
(define (win-newline n [m 1]) (test-srcloc-token 'NEWLINE "\r\n" n m #:skip? #t))

(define test-lexer
  (test-suite
   "Lexer"
   (check-equal? (lex "") empty)

   (check-equal?
    (lex " ")
    (list (space 0)))

   (check-equal?
    (lex "1 1+")
    (list (test-srcloc-token 'INTEGER 1 0)
          (space 1)
          (test-srcloc-token 'INTEGER 1 2)
          (test-srcloc-token 'SYMBOL '+ 3)
          ))

   (check-equal?
    (lex "1\n1+")
    (list (test-srcloc-token 'INTEGER 1 0)
          (newline 1)
          (test-srcloc-token 'INTEGER 1 0 2 1 3)
          (test-srcloc-token 'SYMBOL '+ 1 2 1 4)
          ))

   (check-equal?
    (lex "{-1* -}:+;")
    (list (test-srcloc-token 'BLOCK-START "{" 0)
          (test-srcloc-token 'INTEGER -1 1 1 2)
          (test-srcloc-token 'SYMBOL '* 3)
          (space 4)
          (test-srcloc-token 'SYMBOL '- 5)
          (test-srcloc-token 'BLOCK-END "}" 6)
          (test-srcloc-token 'ASSIGNMENT-OP ":" 7)
          (test-srcloc-token 'SYMBOL '+ 8)
          (test-srcloc-token 'SYMBOL '|;| 9)
          ))

   (check-equal?
    (lex "[50]'23'+")
    (list (test-srcloc-token 'LIST-START "[" 0)
          (test-srcloc-token 'INTEGER 50 1 1 2)
          (test-srcloc-token 'LIST-END "]" 3)
          (test-srcloc-token 'STRING "23" 4 1 4)
          (test-srcloc-token 'SYMBOL '+ 8)
          ))
   ))

(run-tests test-lexer)