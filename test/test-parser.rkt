#lang br
(require golfscript/parser golfscript/tokenizer brag/support rackunit)

(check-equal?
 (parse-to-datum (apply-tokenizer make-tokenizer "1 1+"))
 '(gs-program
   (gs-expr (gs-var 1))
   (gs-expr (gs-var " "))
   (gs-expr (gs-var 1))
   (gs-expr (gs-var "+"))))

(check-equal?
 (parse-to-datum (apply-tokenizer make-tokenizer "1\n1+"))
 '(gs-program
   (gs-expr (gs-var 1))
   (gs-expr (gs-var 1))
   (gs-expr (gs-var "+"))))

(check-equal?
 (parse-to-datum (apply-tokenizer make-tokenizer "{-}:+"))
 '(gs-program
   (gs-expr
    (gs-assignment
     (gs-expr
      (gs-block
       (gs-expr (gs-var "-"))))
     (gs-var "+")))))

(check-equal?
 (parse-to-datum (apply-tokenizer make-tokenizer "[50]'23'+"))
 '(gs-program
  (gs-expr (gs-list (gs-expr (gs-var 50))))
  (gs-expr (gs-string "23"))
  (gs-expr (gs-var "+"))))

(check-equal?
 (parse-to-datum (apply-tokenizer make-tokenizer #<<HERE
{#reminder
+}~
HERE
                                  ))
 '(gs-program
  (gs-expr
   (gs-block (gs-expr (gs-comment "reminder\n")) (gs-expr (gs-var "+"))))
  (gs-expr (gs-var "~"))))
