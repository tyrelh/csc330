# Arguing between Static typing and Dynamic typing

## Claim 1a: Dynamic is more convenient
Dynamic typing lets you build a heterogeneous list or return a "number or a string" without workarounds
```
(define (f y)
  (if (> y 0) (+ y y) "hi"))
(let ([ans (f x)])
  (if (number? ans) (number->string ans) ans))
```
```
datatype t = Int of int
           | String of string
fun f y =
  if y > 0
  then Int(y+y)
  else String "hi"
              
case f x of
    Int i => Int.toString i
  | String s => s
```

## Claim 1b: Static is more convenient
Can assume data has the expected type without cluttering code with dynamic checks or having errors far from the logical mistake
```
(define (cube x)
  (if (not (number? x))
      (error "bad arguments")
      (* x x x)))

(cube 7)
```
```
fun cube x = x * x * x

cube 7
```

## Claim 2a: Static prevents useful programs
Any sound static type system forbids programs that do nothing wrong, forcing programmers to code around limitations
```
(define (f g)
  (cons (g 7) (g #t)))
(define pair_of_pairs
  (f (lambda (x) (cons x x))))
```
```
fun f g = (g 7, g true) (* does not type-check *)

val pair_of_pairs = f (fn x => (x,x))
```

## Claim 2b: Static lets you tag as needed
Rather than suffer time, space, and late-errors costs of tagging everything, statically typed languages let programmers "tag as needed" (e.g., with datatypes)
```
datatype tort = Int of int
              | String of string
              | Cons of tort * tort
              | Fun of tort -> tort
              | ...

if e1
then Fun (fn x => case x of Int i => Int (i*i*i))
else Cons (Int 7, String "hi")
```

## Claim 3a: Static catches bugs earlier
Static typing catches many simple bugs as soon as "compiled"
* Since such bugs are always caught, no need to test for them
* In fact, can code less carefully and "lean on" type-checker
```
(define (pow x) ; curried
  (lambda (y)
    (if (= y 0)
        1
        (+ x ((pow x) (- y 1)))))) ; oops
```
```
fun pow x y = (* does not type-check *)
  if y = 0
  then 1
  else x * pow (x,y-1)
```

## Claim 3b: Static catches only easy bugs
But static often catches only "easy bugs, so you still have to test your functions, which should find the "easy" bugs too.
```
(define (pow x) ; curried
  (lambda (y)
    (if (= y 0)
        1
        (+ x ((pow x) (- y 1)))))) ; oops
```
```
fun pow x y = (* curried *)
  if y = 0
  then 1
  else x + pow x (y-1) (* oops *)
```
## Claim 4a: Static typing is faster
Language implementation:
* Does not need to store tags (space, time)
* Does not need to check tags (time)

Your code:
* Does not need to check arguments and results

## Claim 4b: Dynamic typing is faster
Language implementation:
* Can use optimization to remove some unneccessary tags and tests
```
(let ([x (+ y y)]) (* x 4))
```
* While that is hard (impossible) in general, it is often easier for the performance-criticle parts of a program

Your code:
* Do not need to "code around" type-system limitations with extra tagss, functions, etc

## Claim 5a: Code reuse easier with dynamic
Without a restrictive type system, more code can just be reused with data of different types
* If you use cons cells for everythng, libraries that work on cons cells are useful
* Collections libraries are amazingly useful but often have very complicated static types

## Claim 5b: Code reuse easier with static
* Modern type systems should support reasonable code reuse with features like generics and subtyping
* If you use cons cells for everything, you will confuse what represents what and get hard-to-debug errors
  * Use separate static types to keep ideas separate
  * Static types help avoid library misuse

# So far
Considered 5 things important when writing code:
1) Convenience
2) Not preventing useful programs
3) Catching bugs early
4) Performance
5) Code reuse

Reality:
* Often a lot of prototyping before a spec is stable
* Often a lot of maintenance / evolution after version 1.0

## Claim 6a: Dynamic better for prototyping
Early on, you may not know what cases you need in datatypes and functions
* But static typing disallows code without having all cases; dynamic lets incomplete programs run
* So you make premature commitments to data structures
* And end up writing code to appease the type-checker that you later throw away
* Particularly frustrating while prototyping

## Claim 6b: Static better for prototyping
What better way to document your evolving decisions on data structures and code-cases than with the type system?
* New, evolving code most likely to make inconsistent assumptions

Easy to put in temporary stubs as necessary, such as
```
| _ => raise Unimplemented |
```

## Claim 7a: Dynamic better for evolution
Can change code to be more permissive without affecting old callers
* Example: Take and int or a string instead of an int
* All ML callers must now use a constructor on arguments and pattern-match on results
* Existing Racket callers can be oblivious

old:
```
(define (f x) (* 2 x))
```

new:
```
(define (f x)
  (if (number? x)
      (* 2 x)
      (string-append x x)))
```
```
fun f x = 2 * x
```

new:
```
fun f x =
  case f x of
      Int i => Int (2 * i)
    | String s => String(s ^ s)
```

## Claim 7b: Static better for evolution
When we change type of data or code, the type-checker gives us a "to do" list of everything that must change
* Avoids introducing bugs
* The more of your spec that is in your types, the more the type-checker lists what to change when your spec changes

Example: Changing the return type of a function

Example: Adding a new constructor to a datatype
* Good reason not to use wildcard patterns

Counter-argument: The to-do list is mandatory,
* which makes evolution in pieces a pain
* cannot test part-way through

# Conclusion
* Static vs. dynamic typing is too coarse a question
  * Better question: What should we enforce statically?
* Legitimate trade-offs you should know
  * Rational discussion informed by facts!
* Ideal (?): Flexible languages allowing best-of-both-worlds?
  * Would programmers use such flexibility well? Who decides?
  * "Gradual typing": a great idea still under active research

# Exam
* Concentrate on Section 5
* Section 6 - just do assignment