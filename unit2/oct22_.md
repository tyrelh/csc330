# Streams
A stream is an infinite sequence of values.
* use a **thunk** to delay creating most of the sequence.
  
Division of labour:
* stream producer knows how to create any number of values
* stream consumer decides how many values to ask for

## Using streams
We will represent streams using **pairs** and **thunks**.

Let a stream be a thunk that when called returns a pair:
```
'(next-answer . next-thunk)
```
So given a stream `s`, the client can get any number of elements
* First:
  * `(car (s))`
* Second:
  * `(car ((cdr (s))))`

## Example using streams
This function returns how many stream elements it takes to find one for which function `tester` does not return `#f`:

```
(define (number-until stream tester)
  (letrec ([f (lambda (stream ans)
                (let ([pr (stream)])
                  (if (tester (car pr))
                      ans
                      (f (cdr pr) (+ ans 1)))))])
    (f stream 1)))
```
* `(stream)` generates the pair (save it into `pr`)
* so recursively pass `(cdr pr)`, the thunk for the rest of the infinite sequence

## Making streams
How can we make the next thunk? Recursion!
* The recursive call wont happen until the thunk is called

Example:
```
(define ones (lambda () (cons 1 ones)))

(define nats
  (letrec ([f (lambda (x)
                (cons x (lambda () (f (+ x 1)))))])
    (lambda () (f 1))))

(define powers-of-two
  (letrec ([f (lambda (x)
                (cons x (lambda () (f (* x 2)))))])
    (lambda () (f 2))))
```
Another example:
```
(define ones 
   (lambda () (cons 1 ones)))
```
or
```
(define (ones) (cons 1 ones))
```
# Memoization
* If a function has
  * no side effects
  * does not read mutable memory
* no point in computing it twice for the same arguments
  * can keep a cache of previous result
* net win if
  * maintaining cache is cheaper than recomputing
  * cached results are reused

Similar to promises, but if the function takes arguments, then there are multiple "previous results"

For recursive functions, this memoization can lead to exponentially faster programs
### Memoization example
```
#lang racket

(provide (all-defined-out))

; exponential running time
(define (fibonacci1 x)
  (if (or (= x 1) (= x 2))
    1
    (+ (fibonacci1 (- x 1))
      (fibonacci1 (- x 2)))))

; linear time evaluation
(define (fibonacci2 x)
  (letrec ([f (lambda (acc1 acc2 y)
                (if (= y x)
                    (+ acc1 acc2)
                    (f (+ acc1 acc2) acc1 (+ y 1))))])
    (if (or (= x 1) (= x 2))
        1
        (f 1 1 3))))

; memoized version
; it only memoizes within its call,
; not accross calls
(define fibonacci3
  (letrec([memo null] ; list of pairs (arg . result) 
          [f (lambda (x)
               (let ([ans (assoc x memo)])
                 (if ans 
                     (cdr ans)
                     (let ([new-ans (if (or (= x 1) (= x 2))
                                        1
                                        (+ (f (- x 1))
                                           (f (- x 2))))])
                       (begin 
                         (set! memo (cons (cons x new-ans) memo))
                         new-ans)))))])
    f))
```

# Macros
A macro definition describes how to transform some new syntax into different syntax in the source language
* A macro is one way to implement syntactic sugar:
  * "replace any syntax of the form `e1 andalso e2` with `if e1 then e2 else false`
* macro expansion is the process of rewriting the syntax for each macro use (before compiling)

## Racket Macros
* If you define a macro `m` in Racket, then `m` becomes a new `special form`
* Use `(m ...)` gets expanded according to definition
* It feels like you are adding keywords to the language

Pseudo-example:
```
Expand (my-if e1 then e2 else e3) to (if e1 e2 e3)
```

## Tokenization
* macro systems generally work at the level of tokens not sequences of characters
* must know how programming language tokenizes text
  
## Local Bindings

## Examples
```
(define-syntax my-if            ; macro name
  (syntax-rules (then else)     ; other keywords
    [(my-if e1 then e2 else e3) ; how to use macro
     (if e1 e2 e3)              ; form of expansion
     ]))

(define-syntax comment-out        ; macro name
  (syntax-rules ()                ; other keywords
    [(comment-out ignore instead) ; macro use
     instead                      ; form of expansion
     ]))  
```

## Revisiting delay and force
Should we use a macro instead to avoid clients' explicit thunk?
```
(define (my-delay th)
  (mcons #f th))

(define (my-force p)
  (if (mcar p)
      (mcdr p)
      (begin (set-mcar! p #t)
             (set-mcdr! p ((mcdr p)))
             (mcdr p))))

(f (my-delay (lambda () e)))

(define (f p)
  (... (my-force p) ...))
```

## Delay macro
A macro can put an expression under a thunk
* delays evaluation without explicit thunk
* cannot implement this with a function

Now client should not use a thunk
* Racket's pre-defined delay is a similar macro
```
(define-syntax my-delay
  (syntax-rules ()
    [(my-delay e)
     (mcons #f (lambda() e))]))

(f (my-delay e))
```
## What about a force macro?
* Good macro style would be to evaluate the argument exactly once (use `x` below, not multiple evaluations of `e`)
  * remember this macro expands to the code of its body!
* whis shows it is bad style to use a macro at all here!
* do not use macros when functions do what you want
```
(define-syntax my-force
  (syntax-rules ()
    [(my-force e)
     (let([x e])
       (if (mcar x)
           (mcdr x)
           (begin (set-mcar! x #t)
                  (set-mcdr! p ((mcdr p)))
                  (mcdr p))))]))
```

## Bad macros
These are not equivalent
```
(define-syntax dbl (syntax-rules()[(dbl x)(+ x x)]))
(define-syntax dbl (syntax-rules()[(dbl x)(* 2 x)]))
```
consider:
```
(dbl (begin (print "hi") 42))
```

## More examples
Sometimes a macro should re-evaluate an argument it is passed
* If not, as in `dbl`, then use a local binding as needed:
```
(define-syntax dbl
  (syntax-rules ()
    [(dbl x)
     (let ([y x]) (+ y y))]))
```
```
(define-syntax take
  (syntax-rules (from)
    [(take e1 from e2)
     (- e2 e1)]))
```
## Local variables in macros
Silly example:
```
(define-syntax dbl
  (syntax-rules ()
    [(dbl x) (let ([y 1])
               (* 2 x y))]))
```
Usage:
```
(let ([y 7]) (dbl y))
```
Naive expansion:
```
(let ([y 7]) (let ([y 1])
               (* 2 y y)))
```
But instead Racket **gets it right**, which is part of **hygiene**

Another example:
```
(define-syntax dbl
  (syntax-rules ()
    [(dbl x) (* 2 x)]))
```
Usage:
```
(let ([* +]) (dbl 42))
```
Naive expansion:
```
(let ([* +]) (* 2 42))
```
But again Racket's hygenic macros get this right

## How hygienic macros work
* secretly **renames local variables** in macros with **fresh names**
* looks up variables used in macros where the macro is defined

## More examples
```
#lang racket

(provide (all-defined-out))

;; a loop that executes body hi - lo times
;; notice use of local variables
(define-syntax for
  (syntax-rules (to do)
    [(for lo to hi do body)
     (let ([l lo]
           [h hi])
       (letrec ([loop (lambda (it)
                        (if (> it h)
                            #t
                            (begin body (loop (+ it 1)))))])
         (loop l)))]))

;; example of use
;; (for 1 to 10 do (print "hi"))

;; let2 allows up to two local bindings (with let* semantics) with fewer parentheses
;; than let*
(define-syntax let2
  (syntax-rules ()
    [(let2 () body)
     body]
    [(let2 (var val) body)
     (let ([var val]) body)]
    [(let2 (var1 val1 var2 val2) body)
     (let ([var1 val1])
       (let ([var2 val2])
         body))]))

;; example of use
;; (let2 () 5)
;; (let2 (x 10) x)
;; (let2 (x 10 y 5) (+x y))


;; the special ... lets us take any number of arguments
;; Note: nothing prevents infinite code generation except
;; the macro definer being careful
(define-syntax my-let*
  (syntax-rules ()
    [(my-let* () body)
     body]
    [(my-let* ([var0 val0]
               [var-rest val-rest] ...)
              body)
     (let ([var0 val0])
       (my-let* ([var-rest val-rest] ...)
                body))]))

;; example of use
;; (my-let* () 3) => 3
;; (my-let* ((x 1) (y 2)) (+ x y)) -> 3
;; (my-let* ((x 1) (y 2) (z 3)) (+ x y z)) => 6
```