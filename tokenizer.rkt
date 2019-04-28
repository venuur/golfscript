#lang br
(require "lexer.rkt" brag/support)

(provide make-tokenizer)

(define (make-tokenizer in [path #f])
  (port-count-lines! in)
  (lexer-file-path path)
  (define (next-token) (basic-lexer in))
  next-token)
