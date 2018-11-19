# Intro to Racket

Start every file with `#lang racket`.

All operators are used as prefix (`+ *` etc)

`lambda` denotes an anonymous function

Example:
```
#lang racket


(define x 3)
(define y (+ x 2))

(define cube ; function
  (lambda (x)
    (* x (* x x))))

(define pow ; recursive function
  (lambda (x y)
    (if (= y 0)
        1
        (* x (pow x (- y 1))))))

(pow 2 4)
```

Lots of built in functions take any number of arguments
```
(* x x x)
```

Currying
```
(define pow
  (lambda (x)
    (lambda (y)
      (if (= y 0)
          1
          (* x ((pow x) (- y 1)))))))

(define three-to-the (pow 3))
(define eightyone (three-to-the 4))
(define sixteen ((pow 2) 4))
eightyone
sixteen
```
Sugar for defining curried functions:
```
(define ((pow x) y) 
  (if (= y 0)
      1
      (* x ((pow x) (- y 1)))))

(define three-to-the (pow 3))
(define eightyone (three-to-the 4))
(define sixteen ((pow 2) 4))
eightyone
sixteen
```

* Empty list
  * `null`
* Cons constructor
  * `cons`
* Access head of list
  * `car`
* Access tail of list
  * `cdr`
* Check for empty
  * `null?`

Examples:
```
(define (sum xs)
  (if (null? xs)
      0
      (+ (car xs) (sum (cdr xs)))))

(define (my-append xs ys)
  (if (null? xs)
      ys
      (cons (car xs) (my-append (cdr xs) ys))))

(define (my-map f xs)
  (if (null? xs)
      null
      (cons (f (car xs)) (my-map f (cdr xs)))))

(sum (list 1 2 3 4 5))
(my-append (list 1 2 3) (list 3 4 5))
(my-map (lambda (x) (+ x 1)) (list 1 2 3))
```

Can use `[]` anywhere you would use `()` to enhance readability.

A term (anything in the language) is either:

* An atom, e.g., `#t`, `#f`, `34`, `"hi"`, `null`, `4.0`, `x`, …
* A special form, e.g., `define`, `lambda`, `if` …
  * Macros will let us define our own
* A sequence of terms in parens: `(t1 t2 … tn)`
  * If `t1` a special form, semantics of sequence have own meaning
  * Else call function `t1`

Examples:
```
(+ 3 (car xs)) ;; call + with (car xs) as parm
                   ;; call car with xs

(lambda (x) (if x "hi" #t))
      ;; lambda is a special form => define an anon-function
      ;; if is a special form => if_then_else
```
```
(define (sum xs)
  (if (null? xs) ;; if empty
      0
      (if (number? (car xs)) ;; if the head is a number...
          (+ (car xs) (sum (cdr xs)))
          ;; otherwise assume the head is a list and recurse...
          (+ (sum (car xs)) (sum (cdr xs)))))) 

(sum (list 1 2 3 4))
(sum (list 1 (list 2 3) 4))
```
Can use `cond` instead of nested if-else statements.
```
(define (sum xs)
  (cond [(null? xs) 0]
        [(number? (car xs))
         (+ (car xs) (sum (cdr xs)))]
        [#t (+ (sum (car xs)) (sum (cdr xs)))]))

(sum (list 1 2 3 4))
(sum (list 1 (list 2 3) 4))
```
A variation (skips elements that are not numbers):
```
(define (sum xs)
  (cond [(null? xs) 0]
        [(number? xs) xs]
        [(list? xs)
         (+ (sum (car xs)) (sum (cdr xs)))]
        [#t 0])) ;; if nothing else, simply add a zero

(sum (list 1 2 3 4))
(sum (list 1 (list 2 "b" 3) 4 "a"))
```
## Truthiness
Any value that is not false is true.

## Local Bindings
4 ways to define local variables.
* `let`
  * can bind any number of local variables
  * the expressions are all evaluated in the environment from **before the `let` expression**
  * Example:
  ```
  (define (silly-double x)
  (let ([x (+ x 3)]  ;; uses x the parameter
        [y (+ x 2)]) ;; uses x the parameter
    (+ x y -5)))
  ```
* `let*`
  * the expressions are evaluated in the environment produced from the **previous bindings**
  * same as how **ML let expressions work**
  ```
  (define (silly-double x)
  (let* ([x (+ x 3)] ;; uses x the parameter
         [y (+ x 2)]) ;; uses x the local binding
    (+ x y -8)))
  ```
* `letrec`
  * the expressions are evaluated in the environment that includes **all the bindings**
  ```
  (define (silly-triple x)
  (letrec ([y (+ x 2)]          
           [f (lambda(z) (+ z y w x))] ;; uses y previously
                            ;; defined and w to be defined
           [w (+ x 7)])                
    (f -9)))
  ```
  * `letrec` is ideal for recursion (including mutual recursion)
  ```
  (define (silly-mod2 x)
  (letrec
    ([even? (lambda(x)
              (if (zero? x) #t (odd? (- x 1))))]
     [odd? (lambda(x)
             (if (zero? x) #f (even? (- x 1))))])
  (if (even? x) 0 1)))
  ```
  * **Do not use later bindings**
  * This will cause an error:
  ```
  (define (bad-letrec x)
  (letrec ([y z]    ;; z has not being properly defined
           [z 13])
    (if x y z)))
  ```
* `define`
  * local `define`s is the preferred Racket style, but this course will emphasize `let`, `let*`, and `letrec` distinctions
  * can choose to use them on homework or not

## Top-level
Can refer to later bindings, but only in function bodies.

## REPL
Works slightly different than `let*` or `letrec`.
* More similar to SML shadowing
* Best to avoid recursive function definitions or forward references in REPL
  * actually ok unless you are shadowing something

## Set!
Unlike ML, Racket has assignment statements
* Use them only when **really important**
  ```
  (set! x e)
  ```
* like `x = e` in java or python.

```
(begin e1 e2 ... en)
```
Will evaluate all expressions and the result is `en`

Example:
```
(define b 3)
(define f (lambda (x) 
            (* 1
               (+ x b))))
(define a (f 4))   ; 7
(define c (+ b 4)) ; 7
(set! b 5)
(define z (f 4))   ; 9
(define w c )      ; 7
```

How to protect your functions from using redefined values:
```
(define b 3)
(define f
  (let ([b b])
    (lambda (x) (* 1 (+ x b)))))
```
That `let` statement will make a local copy of `b` in the closure of `f`.

Don't have to program like this. If your function is in a module Racket will set it to constant by default. 

## The truth about cons
`cons` just makes a pair
* often called a `cons` cell
* lists are nested pairs that end with `null`
```
;; not  a proper list, it is a pair!
(define pr (cons 1 (cons #t "hi"))) ; '(1 #t . "hi")
(pair? pr) ; #t
;; this is a proper list
(define lst (cons 1 (cons #t (cons "hi" null))))       
(list? lst) ; #t
       ;; 
(define hi (cdr (cdr pr)))
(define hi-again (car (cdr (cdr lst))))
(define hi-another (caddr lst))
(define no (list? pr))
(define yes (pair? pr))
(define of-course (and (list? lst) (pair? lst)))  
```