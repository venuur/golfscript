#lang br/quicklang
(require "parser.rkt" "tokenizer.rkt")

(provide (rename-out [parse-stx-module-begin #%module-begin])
         syntax)

(define (read-syntax path port)
  (define parse-tree (parse path (make-tokenizer port path)))
  (strip-bindings
   #`(module golfscript-parser-mod golfscript/parse-stx
       #'#,parse-tree)))

(module+ reader (provide read-syntax))

(define-macro (parse-stx-module-begin PARSE-TREE)
  #'(#%module-begin PARSE-TREE))
