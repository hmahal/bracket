#lang br/quicklang 

(define (read-syntax path port)         ; Define func read-syntax with two params, path & port
  (define src-lines (port->lines port)) ; Normally we can read incrementally from port, here we read it in all at once
  (define src-datums (format-datums 
                       '(handle ~a) src-lines)) ; We take src-lines (list) as input and format it data using format-datums function 
  (define module-datum `(module stacker-mod "stacker.rkt" ,@src-datums))
  (datum->syntax #f module-datum))

(provide read-syntax) ;Exports the function from module

(define-macro (stacker-module-begin HANDLE-EXPR ...) ; Define macro with syntax pattern
              ; #' captures lexical context, creates datum and attaches it to sytanx object
              #'(#%module-begin     ; exports module-begin macro from quicklang
                 HANDLE-EXPR ...    ; HANDLE-EXPR is pattern var. using ... will match each line of code passed to macro 
                 (display (first stack))))  ; Print the first item in stack, which should be the result after all ops are processed
(provide (rename-out [stacker-module-begin #%module-begin]))

(define stack empty) ; Initialize stack as an empty list

(define (pop-stack!)
  (define arg (first stack))    ; Set arg to first element of list
  (set! stack (rest stack))     ; Update stack to be rest of the list
  arg)                          ; Return arg

(define (push-stack! arg)
  (set! stack (cons arg stack)))    ; Returns a new pair with arg prepended to stack

(define (handle [arg #f])   ; arg is optional
                (cond
                  [(number? arg) (push-stack! arg)]     ; Check if arg is a number, if so push on to stack
                  [(or (equal? + arg) (equal? * arg))   ; Otherwise if it's + or *, pop items from stack and perform the op
                   (define result (arg (pop-stack!) (pop-stack!)))
                   (push-stack! result)]))   ; Store the operation result in a temp result and push result to stack
(provide handle)
(provide + *)   ; Add bindings for +/* from br/quicklang
