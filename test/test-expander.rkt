#lang br

(require golfscript/expander rackunit)

;;; Builting function testing (sans parsing)
(check-equal?
 (begin
   (gs-var 5)
   (gs-~)
   (gs-pop!))
 (bitwise-not 5))

(check-equal?
 (begin
   (gs-string "1 2+")
   (gs-~)
   (gs-pop!))
 3)

(check-equal?
 (begin
   (gs-block (gs-var 1) (gs-var 2) (gs-var "+"))
   (gs-~)
   (gs-pop!))
 3)


(check-equal?
 (begin
   (gs-list (gs-var 1) (gs-var 2) (gs-var 3))
   (gs-~)
   (for/list ([i (in-range 3)]) (gs-pop!)))
 '(3 2 1))
