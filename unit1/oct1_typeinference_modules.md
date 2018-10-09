# Type Inference

Static Typing
* Reject programs that dont type

Dynamic Typing
* Run program and check types at runtime

## Implicitly Typed
Type of param can be inferred by the operations on it within the funciton

Example:
```
fun f x = (* infer val f : int -> int *)
  if x > 3
  then 42
  else x * 2

fun g x = (* report type error *)
  if x > 3
  then true
  else x * 2
```
### -> Parsing -> Type Inference -> Type Checking

## Steps
* Determine types of bindings **in order**
* for each val or fun:
    * look for constraints
* type error if any constraint doesnt hold
* use type variables for unconstrained types (a')

Example:
```
val x = 42 (* val x : int *)
fun f (y, z, w) =
   if y (* y must be bool *)
   then z + x (* z must be int *)
   else 0 (* both branches have same type *)
(* 
   w is not bound to anything => 'a
   f must return an int
   f must take a bool * int * ANYTHING
   so val f : bool * int * 'a -> int
*)
(*
    val x = 42 : int
    val f = fn : bool * int * 'a -> int
*)
```
Other examples done in lecture:
```
length (T1*T2*T3) -> T4
T4 = (T1*T2*T3)
T2 = T1
T1 is unbound => a'
T3 is unbound => b'
f: (a'*a'*b') -> (a'*a'*b')
```
```
fun compose (f, g) = fn x => f (g x)

compose: T1 -> T2
f: T3 -> T4
g: T5 -> T6
T2: T7 -> T8
x: T7
the function will return the return type of f
the anon function returns T4
T8 = T4
x is the parameter to g
T7 = T5
the return type of g is the input type of f
T6 = T3
T1 = (T3 -> T4, T5 -> T6)
T1 = (T3 -> T4, T5 -> T3)
T2 = (T5 -> T4)
compose: (T3 -> T4, T5 -> T3) -> (T5 -> T4)
compose: ((a' -> b')*(c' -> a')) -> (c' -> b')
```
## Mutual recursion
* Two functions need to call each other
### New feature
`and` keyword allows you to chain multiple bindings to be done simultainiously. The bindings themselves have access to all the bindings.
```
fun f1 p1 = e1
and f2 p2 = e2
and f3 p3 = e3
```

## Finite-state machine
Each state of computation is a function
* "State transition" is "call another fnction" with "rest of input"
* Generalized to any finite state machine
```
fun state1 input_left = ...
and state2 input_left = ...
and ...
```

Example:
```
fun match xs =
  let
    fun s_need_one xs = 
     case xs of 
         [] => true
      |  1::xs' => s_need_two xs'
      |  _ => false
    and s_need_two xs =
     case xs of 
         [] => false
      |  2::xs' => s_need_one xs'
      |  _ => false
  in
    s_need_one xs
  end;
val x = match [1,2,3]
val y = match [1,2,1,2,1,2]
```
Types:
```
val match = fn : int list -> bool
val x = false : bool
val y = true : bool
```
### Work around
```
fun earlier (x, f) = ..... f(y)
...
fun later x = ... earlier(x, later)
```


# Modules
Syntax:
```
structure MyModule = struct 
  bindings 
end
```
Outside of the module, bindings can be used by calling `ModuleName.bindingName`

Examples:
```
List.foldl
String.toUpper
```
```
structure MyMathLib =
struct

fun fact x =
  if x=0
  then 1
  else x * fact(x-1)

val half_pi = Math.pi / 2

fun doubler x = x * 2

end
```

Gives us namespace management.

can use `open ModuleName` to get "direct access" to a modules bindings.
* not neccessary, just convenient, often bad style

### signatures
A signature is a type for a module.
* Like an interface?
```
signature MATHLIB =
sig
  val fact : int -> int
  val half_pi : real
  val doubler : int -> int
end
    
structure MyMathLib :> MATHLIB =
struct
  fun fact x = ...
  val half_pi = Math.pi / 2.0
  fun doubler x = x * 2
end
```
contract and implementation