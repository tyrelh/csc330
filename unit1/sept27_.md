# Map Filter Fold (reduce in javascript)
```
fun square_and_sum_positives(lst) = 
    fold(map(filter(lst, fn x => x > 0), fn x => x * x), fn (x, y) => x + y, 0)
```
# What is lexical scope good for?
* We know the rule for lexical scope and function closures
    * Now what is it good for
  
A partial but wide-ranging list:
* Pass functions with private data to iterators: Done
* Combine functions (e.g., composition)
* Currying (multi-arg functions and partial application)
* Callbacks (e.g., in reactive programming)

# Combine functions
Canonical example is function composition:
```
fun compose (f, g) = fn x => f(g(x))
```
or with the infix operator `o`:
```
val compose = f o g
```
Examples (third version is best):
```
fun sqrt_of_abs i = Math.sqrt(Real.fromInt(abs i))
fun sqrt_of_abs i = (Math.sqrt o Real.fromInt o abs) i
val sqrt_of_abs = Math.sqrt o Real.fromInt o abs
```
* Note the use of `val`

## Left-to-right or right-to-left?
As in math, function composition is "right to left"
* "take absolute value, convert to real, and take square root"
* "square root of the conversion to real of absolute value"

"Pipelines" of functions are common in functional programming and many programmers prefer left-to-right
* Can define our own infix operator
* This one is very popular (and predefined) in F#
```
infix |>   (* define this token as an infix operator *)
fun x |> f = f x

fun sqrt_of_abs i =
  i |> abs |> Real.fromInt |> Math.sqrt
```
* this is F#, not SML.

## Another Example
* "Backup function"
```
fun backup1 (f,g) =
  fn x => case f x of
              NONE => g x
            | SOME y => y
```

# Currying
* Recall every ML function takes exactly one argument
* Previously encoded n arguments via one n-tuple
* **Another way**: Take one argument and return a function that takes another argument and…
    * Called "**currying**" after famous logician Haskell Curry

Example:
```
val sorted3 =
 fn x =>
    fn y =>
       fn z =>
          z >= y andalso y >= x
                                  
val t1 = ((sorted3 7) 9) 11
```
* Calling `(sorted3 7)` returns a closure with:
    * Code: `fn y > fn z => z > y andalso y >= x`
    * Environment: maps `x` to `7`
* Calling that closure with `9` returns a closure with:
    * Code: `fn z > z > y andalso y >= x`
    * Environment: maps `x` to `7`, `y` to `9`
* Calling that closure with `11` returns `true`

We can rewrite:
```
(((e1 e2) e3) e4)
```
as:
```
e1 e2 e3 e4
```
so instead of 
```
((sorted3 7) 9) 11
```
we can write
```
sorted3 7 9 11
```

## Syntactic sugar
```
val sorted3 =
 fn x =>
    fn y =>
       fn z =>
          z >= y andalso y >= x
                                  
val t1 = ((sorted3 7) 9) 11
```
* In general, `fun f p1 p2 p3 … = e`,
* means `fun f p1 = fn p2 => fn p3 => … => e`
* So instead of `val sorted3 = fn x => fn y => fn z => …`
* or `fun sorted3 x = fn y => fn z => …`,
* can just write `fun sorted3 x y z = x >=y andalso y >= x`
* Callees can just think "multi-argument function with spaces instead of a tuple pattern"
    * Different than tupling;
    * caller and callee must use same technique

## Final version
```
fun sorted3 x y z = 
  z >= y andalso y >= x

val t1 = sorted3 7 9 11
```
As elegant syntactic sugar (even fewer characters than tupling) for:
```
val sorted3 = fn x => fn y => fn z =>
                 z >= y andalso y >= x

val t1 = ((sorted3 7) 9) 11
```
## Fold is curried
```
fun sum_list xs = 
    List.foldl (Int.+) 0 xs
```
or:
```
val sum_list = List.foldl (Int.+) 0

sum_list [1, 2, 3]
```
### Curried fold
```
fun fold f acc xs =
  case xs of
      [] => acc
    | x::xs' => fold f (f(acc,x)) xs'

fun sum xs = fold (fn (x,y) => x+y) 0 xs

val total = sum [1,2,3,4]
```
# "Too Few Arguments"
* Previously used currying to simulate multiple arguments
* But if caller provides "too few" arguments, we get back a closure "waiting for the remaining arguments"
* Called partial application
* Convenient and useful
* Can be done with any curried function

No new semantics here: a pleasant idiom

Example:
```
fun fold f acc xs =
  case xs of
      [] => acc
    | x::xs' => fold f (f(acc,x)) xs'

fun sum_inferior xs = fold (fn (x,y) => x+y) 0 xs

val sum = fold (fn (x,y) => x+y) 0
```

## Unnecessary function wrapping
```
fun sum_inferior xs = fold (fn (x,y) => x+y) 0 xs

val sum = fold (fn (x,y) => x+y) 0
```

# Iterators
Partial application is particularly nice for iterator-like functions

Example:
```
fun exists predicate xs =
  case xs of
      [] => false
    | x::xs' => predicate x
                orelse exists predicate xs'

val no = exists (fn x => x=7) [4,11,23]

val hasZero = exists (fn x => x=0)
```
## The Value Restriction Appears
If you use partial application to create a polymorphic function, it may not work due to the value restriction
* Warning about "type vars not generalized"
    * And won't let you call the function
```
val pairWithOne = List.map (fn x => (x,1))
val pairs = pairWithOne [1,2,3]
```
```
stdIn:3.5-3.43 Warning: type vars not generalized because of
value restriction are instantiated to dummy types (X1,X2,...)
stdIn:4.5-4.32 Error: operator and operand don't agree [overload conflict]
operator domain: ?.X1 list
operand:         [int ty] list
in expression:
pairWithOne (1 :: 2 :: 3 :: nil)
```
one solution:
```
fun pairWithOne lst = List.map (fn x => (x,1)) lst
val pairs = pairWithOne [1,2,3]
```
## More combining funcions
* What if you want to curry a tupled function or vice-versa?
* What if a function's arguments are in the wrong order for the partial application you want?
```
fun range(i,j) = if i > j 
   then [] 
   else i::range (i+1,j)

val countup = range 1  (* this will not work *)

fun curry f x y = f(x,y)

val countup = curry range 1

val xs = countup 7 (* [1,2,3,4,5,6,7] *)
```
It is easy to write higher-order wrapper functions:
```
fun curry f x y = f (x,y)
fun uncurry f (x,y) = f x y
fun invert_currry f x y = f y x
```
# Efficiency
* Currying and passing tuples are both constant time operations.
* Dont consider this until small performance differences matter.

# ML has (separate) mutation
Mutable data structures are okay sometimes
## References
* `t ref` where `t` is a type
* New expressions:
    * `ref e` to create a reference with initial contents `e`
    * `e1 := e2` to updates contents
    * `!e` to retrieve contents

Example:
```
val x = ref 42
val y = ref 42
val z = x
val _ = x := 43
val w = (!y) + (!z) (* 85 *)
(* x + 1 does not type-check *)
```
* The variable bound to the reference is still immutable
* But now the reference can change

# Callbacks
A common idiom: Library takes functions to apply later, when an event occurs:
* When a key is pressed, mouse moves, data arrives
* When the program enters some state

A library may accept multiple callbacks
* Different callbacks may need different private data with different types

## Mutable state
We really do want the "callbacks registered" to change when a function to register a callback is called.

## Example callback library
Library maintains mutable state for "what callbacks are there" and provides a function for accepting new ones
* A real library would also support removing them, etc.
* In example, callbacks have type int->unit

So the entire public library interface would be the function for registering new callbacks:
```
val onKeyEvent : (int -> unit) -> unit
```
Because callbacks are executed for side-effect, they may also need mutable state.
```
val cbs : (int -> unit) list ref = ref []

fun onKeyEvent f =
  cbs := f :: (!cbs)

fun onEvent i =
  let
    fun loop fs =
      case fs of
          [] => ()
        | f::fs' => (f i; loop fs')
  in
    loop (!cbs)
  end
```
## Clients
Can only register an int -> unit, so if any other data is needed, must be in closure's environment
* And if need to "remember" something, need mutable state
* 
Examples:
```
val timesPressed = ref 0
val _ = onKeyEvent (fn _ =>
                       timesPressed := (!timesPressed) + 1)
fun printIfPressed i = (* create a callback if key i is pressed *)
  onKeyEvent (fn j =>
                 if i=j
                 then print ("pressed " ^ Int.toString i) (* returns unit *)
                 else ())

val _ = printIfPressed 4
val _ = printIfPressed 11
val _ = printIfPressed 23
val _ = printIfPressed 4

val i = !timesPressed
(* send an event *)
val _ = onEvent 11; (* prints "pressed 11" *)
val _ = onEvent  5;
val j = !timesPressed
val _ = onEvent  4; (* prints "pressed 4" twice *)
```