#lang brag
gs-program : gs-expr*
@gs-expr : gs-var
         | gs-block
         | gs-string
         | gs-list
         | gs-assignment
         | gs-comment
gs-var : WORD | SYMBOL | INTEGER
gs-block : /BLOCK-START gs-expr* /BLOCK-END
gs-string : STRING
gs-list : LIST-START | LIST-END
gs-assignment : gs-expr /ASSIGNMENT-OP gs-var
gs-comment : COMMENT
