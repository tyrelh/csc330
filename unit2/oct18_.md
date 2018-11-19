# Scope
`let` uses scope above
```
f x: parm = 5
  let (
    x <- 5 + 1
    y <- 5 * 2)
    (cons x y) -> 6.10
```
`let*` looks at closest scope first
```
f x: parm = 5
  let* (
    x <- 5 + 1
    y <- 6 * 2
  )(cons x y) -> 6.12
```
`letrec` strictly uses close scope
```
f x: parm = 5
  letrec (
    x <- x + 1 ... RUNTIME ERROR, x UNDEFINED
  )
```

# Cons
`set!` does not change list contents.
```
(define x (cons 14 null))
(define y x)             
(set! x (cons 42 null))   ;; create a new list!!
(define fourteen (car y))  ;; y still has car 14
```

There exist mutable pairs if you need them
* `mcons`	create a mutable cons
* `mcar`	get the car of mcons
* `mcdr`	get the cdr of mcons
* `mpair?`	is it a mutable pair?
* `set-mcar!`	set the car of an mcons
* `set-mcdr!`	set the cdr of an mcons

```racket
(define x (mcons 1 2))
x
-> (mcons 1 2)
(set-mcar! x 2)
x
-> (mcons 2 2)
```
```
(define mpr (mcons 10 (mcons 3 null)))
(list? mpr)
-> #f
```
# Delayed Evaluation
Lazy evaluation
* evaluate one at a time
Eager evaluation
* evaluate all first

Calling `factorial-bad` never terminates.
```racket
(define (my-if-bad x y z)
  (if x y z))

(define (factorial-bad n)
  (my-if-bad (= n 0)
             1  ;; must evaluate both branches before calling my-if-bad
             (* n (factorial-bad (- n 1))))) 
```
## Thunks: delayed evaluation
A zero-argumant function used to delay evaluation is called a *thunk*.
```
(define (my-if x y z)
  (if x (y) (z))) ;; evaluate either branch, but only one

(define (fact n)
  (my-if (= n 0)
         (lambda() 1)  ;; create thunk
         (lambda() (* n (fact (- n 1)))))) ;; create thunk
```

### Key point
To create a *thunk* around an expression simply wrap it in a lambda

```
e

(define e-thunk (lambda () e))
```
To evaluate e:
```
(e-thunk)
```
### Best of both worlds: Lazy evaluation
* Assuming some expensive computation has no side effects, ideally we would:
  * Not compute it until needed
  * Remember the answer so future uses complete immediately
  * Called lazy evaluation
* Languages where most constructs, including function arguments, work this way are lazy languages
  * Haskell
* Racket predefines support for promises,
  * But we are going to make our own
  * Thunks and mutable pairs are enough

## Promises
Using Delay and force
* Use a mutable pair
  * first element tells us if it has been evaluated

If the first element contains false, then the second contains the thunk expression. Execute the second piece and replace the thunk with the result. set the first to true

Now if the first is true, just return the second piece which is the result.

```
(define (my-delay th)
  (mcons #f th))

(define (my-force p) 
  (if (mcar p) ; if mcar is true return cdr
      (mcdr p)
      ; otherwise evaluate and save in cdr
      (begin (set-mcar! p #t)
             (set-mcdr! p ((mcdr p)))
             (mcdr p))))
```

```
(define x (#f (lambda () (* 3 2))))
(my-force x) ; executes second piece of promise
(my-force x) ; returns second piece of promise
```

# Streams
A stream is an infinite sequence of values.
* Cannot make all the values
* Use a *thunk* to delay creating most of the sequence

Division of labour:
* Stream producer knows how to create any number of values
* Stream consumer decides how many values to ask for  

## Using streams
Represent streams using pairs and thunks

Let a stream be a thunk that when called returns a pair:
```
'(next-answer . next)
```
So given a stream `s`, the client can get any number of elements
* First
  ```
  ```