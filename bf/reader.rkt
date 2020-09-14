#lang br/quicklang
(require "parser.rkt")

(define (read-syntax path port)
  (define parse-tree (parse path (make-tokenizer port)))
  (define module-datum `(module bf-mod "funexpander.rkt" ,parse-tree))
  (datum->syntax #f module-datum))
(provide read-syntax)

(require brag/support) ; Require brag/support to get lexer
(define (make-tokenizer port)
  (define (next-token)
    (define bf-lexer
      (lexer                            ; Lexer is a built-in function in brag
        [(char-set "><+-.,[]") lexeme]  ; Provide valid tokens to the lexer and pass it to lexeme.
        [any-char (next-token)]))       ; We ignore matches of any other characters
      (bf-lexer port))
  next-token)
