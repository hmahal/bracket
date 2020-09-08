#lang br/quicklang

; The ellipsis are in essence a way to specify pattern matching in racket? When we define what we do to the first element,
; we also define what to do with rest of the elements. In the following example, we simply just take elements and append to array.
(define-macro (lister ARG ...)
              #'(list ARG ...))

(lister "foo" "bar" "baz") ; ("foo" "bar" "baz")

; Here we make pairs of args and 42
(define-macro (wrap ARG ...)
              #'(list '(ARG 42) ...))

(wrap "foo" "bar" "baz") ; (("foo" 42) ("bar" 42) ("baz" 42))
