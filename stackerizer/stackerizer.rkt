#lang br/quicklang

(provide + *)

(define-macro (stackerizer-mb EXPR)
              ; Flatten the s-exp and print it out, equivalent to what stacker takes in as input
              #'(#%module-begin 
                 (for-each displayln (reverse (flatten EXPR)))))
(provide (rename-out [stackerizer-mb #%module-begin]))

; We use a macro to generate the macro-cases that will be used for different operators. Saves us from having to rewrite the same code
; with minor differences
(define-macro (define-ops OP ...)
    ; Syntax templates can only have one top level expression, we use begin to wrap our two expressions, we define the template for the
    ; first param and it gets applied to rest through ...
    #'(begin
        ; Just like define-macro but instead of a single pattern, multiple patterns can be specified and the first one that evals to
        ; match is used.
        (define-macro-cases OP
            ; Matches single argument addition call, return syntax-object matching the first arg. 
            [(OP FIRST) #'FIRST]
            ; For rest of the cases, we take variadic addition and convert it into dyadic addition. Meaning we take addition with any
            ; number of params and convert it into a pair of addition params. E.g. (+ 1 2 3 4 5) -> (+ 1 (+ 2 (+ 3 (+ 4 5))))
            ; We break the params apart with first param and all the remaining params represented by NEXT ..., which can take 0 or more
            ; params. Since we do (+ NEXT ...), it gets passed to our macro again through recursion and keeps going until all params are
            ; exhausted. One thing to note is that is just do NEXT ..., it'll match our macro generating macro and the ones for specific
            ; operators. We get around it by using (... ...) special form, we avoid that issue.
            [(OP FIRST NEXT (... ...)) #'(list 'OP FIRST (OP NEXT (... ...)))])
        ...))

(define-ops + *)
