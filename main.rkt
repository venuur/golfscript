#lang br/quicklang
(require "parser.rkt" "tokenizer.rkt")

(module+ reader (provide read-syntax))

(define (read-syntax path port)
  (define parse-tree (parse path (make-tokenizer port path)))
  (strip-bindings
   #`(module golfscript-mod golfscript/expander
       #,parse-tree)))
