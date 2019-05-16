#lang racket

(require rackunit)
(require rackunit/text-ui)
(require racket/sandbox)


(define (eval-golfscript script-body)
  (let* ([script (string-join (list "#lang golfscript" script-body) "\n")]
         [evaluator (call-with-trusted-sandbox-configuration
                     (λ () (make-module-evaluator script)))])
    (evaluator '(gs-program-result))))

(define-check (check-script-output script-body expected-output)
  (define actual-output (eval-golfscript script-body))
  (with-check-info
      (('actual-output actual-output)
       ('expected-output expected-output))
    (unless (equal? actual-output expected-output) (fail-check))))

(define test-tilde-op
  (test-suite
   "~ operator"
   (check-script-output "5~" "-6")
   (check-script-output "{1 2+}~" "3")
   (check-script-output "[1 2 3]~" "123")
   (check-script-output "\"1 2+\"~" "3")
   ))

(define test-add-op
  (test-suite
   "+ operator"
   (check-script-output "1 2+" "3")
   ))

(define test-at-op
  (test-suite
   "@ operator"
   (check-script-output "1 2 3 4@" "1342")
   ))

(define test-backtick-op
  (test-suite
   "` operator"
   (check-script-output "1`" "1")
   (check-script-output "[1 [2] 'asdf']`" "[1 [2] \"asdf\"]")
   (check-script-output "\"1\"`" "\"1\"")
   (check-script-output "{1}`" "{1}")
   ))

(define test-comments
  (test-suite
   "Comments"
   (check-script-output "#ignored from here" "")
   ))

(define test-exclamation-op
  (test-suite
   "! operator"
   (check-script-output "1!" "0")
   (check-script-output "{asdf}!" "0")
   (check-script-output "\"\"!" "1")
   (check-script-output "0!" "1")
   (check-script-output "[]!" "1")
   (check-script-output "{}!" "1")
   ))

(define test-dollar-op
  (test-suite
   "$ operator"
   (check-script-output "1 2 3 4 5 1$" "123454")
   ))


(define test-builtins
  (test-suite
   "Builtins"
   test-tilde-op
   test-add-op
   test-at-op
   test-backtick-op
   test-comments
   test-exclamation-op
   test-dollar-op
   ))

(run-tests test-builtins)