#lang br/quicklang
(require "parser.rkt" "tokenizer.rkt")

(provide (rename-out [parse-only-module-begin #%module-begin]))

(define (read-syntax path port)
  (define parse-tree (parse path (make-tokenizer port path)))
  (strip-bindings
   #`(module golfscript-parser-mod golfscript/parse-only
       #,parse-tree)))

(module+ reader (provide read-syntax))

(define-macro (parse-only-module-begin PARSE-TREE)
  #'(#%module-begin 'PARSE-TREE))
