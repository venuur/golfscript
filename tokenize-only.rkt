#lang br/quicklang
(require brag/support "tokenizer.rkt")

(provide (rename-out [tokenize-only-module-begin #%module-begin]))

(define (read-syntax path port)
  (define tokens (apply-tokenizer make-tokenizer port))
  (strip-bindings
   #`(module golfscript-tokenize-only-mod golfscript/tokenize-only
       #,@tokens)))

(module+ reader (provide read-syntax))

(define-macro (tokenize-only-module-begin TOKEN ...)
  #'(#%module-begin (list TOKEN ...)))
