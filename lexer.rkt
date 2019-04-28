;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
#lang br
(require brag/support)

(provide basic-lexer)

(define-lex-abbrev letters (:+ (char-set "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ")))
(define-lex-abbrev digits (:+ (char-set "0123456789")))
(define-lex-abbrev newline (:or "\r\n" (char-set "\r\n")))

(define basic-lexer
  (lexer-srcloc
   ;; words--original regex: [a-zA-Z_][a-zA-Z0-9_]*
   [(:seq (:+ (:or letters "_"))
          (:* (:or letters "_" digits)))
    (token 'WORD lexeme)]
   ;; strings--original regex part: '(?:\\.|[^'])*'?|\"(?:\\.|[^\"])*\"?
   [(:or (from/to "\"" "\"") (from/to "'" "'"))
    (token 'STRING (substring lexeme 1 (sub1 (string-length lexeme))))]
   ;; integers--original regex part: -?[0-9]+
   [(:seq (:? "-") (:+ digits))
    (token 'INTEGER (string->number lexeme))]
   ;; comments--original regex part: #[^\n\r]*
   [(from/to "#" "\n")
    (token 'COMMENT (substring lexeme 1))]
   ;; block start/end--not in original, but convenient for syntax.
   [(:= 1 "{") (token 'BLOCK-START lexeme)]
   [(:= 1 "}") (token 'BLOCK-END lexeme)]
   ;; list start/end--not in original, but convenient for syntax.
   [(:= 1 "[") (token 'LIST-START lexeme)]
   [(:= 1 "]") (token 'LIST-END lexeme)]
   ;; assignment--not in original, but it's part of syntax, not a function.
   [(:= 1 ":") (token 'ASSIGNMENT-OP lexeme)]
   ;; ignore newlines--not explicit in original, but I don't think they're symbols.
   [(:= 1 newline)
    (token 'NEWLINE lexeme #:skip? #t)]
   ;; symbols (any single character except newlines)--original regex part: ."
   [(:~ (char-set "\r\n"))
    (token 'SYMBOL lexeme)]
   ))
