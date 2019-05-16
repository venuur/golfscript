#lang br
(require "../parser.rkt" "../tokenizer.rkt")
(require brag/support)
(require rackunit rackunit/text-ui)

(define test-parser
  (test-suite
   "Parser"
   (check-equal?
    (parse-to-datum (apply-tokenizer make-tokenizer "1 1+"))
    '(gs-program
      (gs-var 1)
      (gs-var | |)
      (gs-var 1)
      (gs-var +)))

   (check-equal?
    (parse-to-datum (apply-tokenizer make-tokenizer "1\n1+"))
    '(gs-program
      (gs-var 1)
      (gs-var 1)
      (gs-var +)))

   (check-equal?
    (parse-to-datum (apply-tokenizer make-tokenizer "{-}:+"))
    '(gs-program
      (gs-assignment
       (gs-block
        (gs-var -))
       (gs-var +))))

   (check-equal?
    (parse-to-datum (apply-tokenizer make-tokenizer "[50]'23'+"))
    '(gs-program
      (gs-list "[")
      (gs-var 50)
      (gs-list "]")
      (gs-string "23")
      (gs-var +)))

   (check-equal?
    (parse-to-datum (apply-tokenizer make-tokenizer "{#reminder\n+}~"))
    '(gs-program
      (gs-block
       (gs-comment "reminder\n")
       (gs-var +))
      (gs-var ~)))
   ))

(run-tests test-parser)