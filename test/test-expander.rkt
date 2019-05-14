#lang br

(require golfscript/expander rackunit)

;;; Builting function testing (sans parsing)

;;; ~
(check-equal?
 (begin
   (gs-push! 5)
   (gs-~)
   (gs-pop!))
 (bitwise-not 5))

(check-equal?
 (begin
   (gs-push! "1 2+")
   (gs-~)
   (gs-pop!))
 3)

(check-equal?
 (begin
   (gs-push! (gs-block-data (λ () (gs-push! 1) (gs-push! 2) (gs-push! +)) "{1 2+}"))
   (gs-~)
   (gs-pop!))
 3)

#;(check-equal?
 (begin
   (gs-list "[")
   (gs-var 1)
   (gs-var 2)
   (gs-var 3)
   (gs-list "]")
   (gs-~)
   (for/list ([i (in-range 3)]) (gs-pop!)))
 '(3 2 1))

;;; `
#;(check-equal?
 (begin
   (gs-var 1)
   (gs-backtick)
   (gs-pop!))
 "1")

#;(check-equal?
 (begin
   (gs-list "[")
   (gs-var 1)
   (gs-list "[")
   (gs-var 2)
   (gs-list "]")
   (gs-string "asdf")
   (gs-list "]")
   (gs-backtick)
   (gs-pop!))
 "[1 [2] \"asdf\"]")
