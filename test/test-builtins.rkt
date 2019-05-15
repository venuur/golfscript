#lang racket

(require rackunit)

(define (check-builtin testfile expected)
  (displayln `(check-builtin ,testfile ,expected))
  (define result (parameterize ([current-output-port (open-output-nowhere)])
                   (dynamic-require (string-append "builtins/" testfile) 'gs-program-result)))
  (check-equal?
   (result)
   expected))

(check-builtin "test-gs-+01.rkt" "3")
(check-builtin "test-gs-tilde01.rkt" "-6")
(check-builtin "test-gs-tilde02.rkt" "3")
(check-builtin "test-gs-tilde03.rkt" "123")
(check-builtin "test-gs-tilde04.rkt" "3")
(check-builtin "test-gs-backtick01.rkt" "1")
(check-builtin "test-gs-backtick02.rkt" "[1 [2] \"asdf\"]")
(check-builtin "test-gs-backtick03.rkt" "\"1\"")
(check-builtin "test-gs-backtick04.rkt" "{1}")
(check-builtin "test-gs-exclamation01.rkt" "0")
(check-builtin "test-gs-exclamation02.rkt" "0")
(check-builtin "test-gs-exclamation03.rkt" "1")
(check-builtin "test-gs-exclamation04.rkt" "1")
(check-builtin "test-gs-exclamation05.rkt" "1")
(check-builtin "test-gs-exclamation06.rkt" "1")