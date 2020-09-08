#lang br/quicklang 

(define (read-syntax path port)         ; Define func read-syntax with two params, path & port
  (define src-lines (port->lines port)) ; Normally we can read incrementally from port, here we read it in all at once
  (define src-datums (format-datums 
                       '~a src-lines)) ; We take src-lines (list) as input and format it data using format-datums function 
  ; Instead of formatting each line as (handle val), instead we will wrap all the args using handle-args function
  (define module-datum `(module stacker-mod "funstacker.rkt" (handle-args ,@src-datums)))
  (datum->syntax #f module-datum))

(provide read-syntax) ;Exports the function from module

(define-macro (stacker-module-begin HANDLE-ARGS-EXPR) ; Define macro with syntax pattern
              ; #' captures lexical context, creates datum and attaches it to sytanx object
              #'(#%module-begin             ; exports module-begin macro from quicklang
                 HANDLE-ARGS-EXPR           ; HANDLE-ARGS-EXPR doesn't need ... since we already wrapped all vals in it in our reader
                 (display (first HANDLE-ARGS-EXPR))))  ; handle-args will return the finished stack so we print the result from it
(provide (rename-out [stacker-module-begin #%module-begin]))

; . args implies that args is rest of the arguments being passed to the function. If there are any other positional params they must
; come before the 'rest args'.
(define (handle-args . args)
  ; for/fold iterates over a list, our args in this case, and returns an accumulator each pass.
  ; Each pass doesn't modify the accumulator but replaces it with a new one and the loop returns the accumulator as it was on the last
  ; pass.
  (for/fold 
    ([stack-acc empty])     ; Initial accumulator, empty list.
    ([arg (in-list args)]   ; Iterator to loop over, in-list is a sequence constructor which helps to generate more efficient code. 
    ; ([arg args]           ; A simple iterator can just be this line. 
     #:unless (void? arg))  ; Guard experssion, this allows us to handle empty lines in our code
    (cond
      [(number? arg) (cons arg stack-acc)]
      [(or (equal? * arg) (equal? + arg))
       (define result
         (arg (first stack-acc) (second stack-acc)))
       ; We drop the 2 elements from stack once we have used them.
       (cons result (drop stack-acc 2))])))
(provide handle-args)
(provide + *)   ; Add bindings for +/* from br/quicklang
