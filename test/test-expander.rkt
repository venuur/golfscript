#lang br

(require golfscript/expander rackunit)

;;; Builting function testing (sans parsing)

;;; ~
(check-equal?
 (begin
   (gs-var 5)
   (gs-~)
   (gs-pop!))
 (bitwise-not 5))

;; Fails because of undefined identifier. The %:top macro is not available here
;; which would normally handle undefined variables.
;(check-equal?
; (begin
;   (gs-string "1 2+")
;   (gs-~)
;   (gs-pop!))
; 3)

(check-equal?
 (begin
   (gs-block (gs-var 1) (gs-var 2) (gs-var "+"))
   (gs-~)
   (gs-pop!))
 3)


(check-equal?
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
(check-equal?
 (begin
   (gs-var 1)
   (gs-backtick)
   (gs-pop!))
 "1")

(check-equal?
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
