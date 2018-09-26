## Insertion into Tree
```
datatype tree =>
    emptyTree
    | Tree of int * tree * tree

fun insert (theTree:tree, i:int) =
    case theTree of
        emptyTree => Tree(i, emptyTree, emptyTree)
        | Tree(v, l, r) =>
            if v > i
            then Tree(v, l, insert(i, r))
            else Tree(v, insert(i, l), r)
    
```
#
Libraries are called *structures* in SML
Example:
```
List.hd
List.tl
List.append
List.concat
Int.+
Real.+
```
Some do not need the qualifier:
```
hd
tl
+
```
# Tail Recursion
* Where reasonably elegant, feasible, and important, rewriting functions to be tail-recursive can be much more efficient – Tail-recursive: recursive calls are tail-calls

* There is a methodology that can often guide this transformation: – Create a helper function that takes an accumulator – Old base case becomes initial accumulator – New base case becomes final accumulator

```
fun fact n = if n=0 then 1 else n*fact(n-1)

fun fact n =
  let
    fun aux(n,acc) =
      if n=0
      then acc
      else aux(n-1,acc*n)
  in
    aux(n,1)
  end
val x = fact 3
```
```
fun sum xs =
  case xs of
      [] => 0
    | x::xs' => x + sum xs'

fun sum xs =
  let
    fun aux(xs,acc) =
      case xs of
          [] => acc
        | x::xs' => aux(xs',x+acc)
  in
    aux(xs,0)
  end
```
```
fun rev xs =
  case xs of
      [] => []
    | x::xs' => (rev xs') @ [x]
                                
fun rev xs =
  let fun aux(xs,acc) =
        case xs of
            [] => acc
          | x::xs' => aux(xs',x::acc)
  in
    aux(xs,[])
  end
```
*Aside: Look into Rust.*

## Always tail-recursive?
* There are certainly cases where recursive functions cannot be evaluated in a constant amount of space
    * Most obvious examples are functions that process trees
* In these cases, the natural recursive approach is the way to go – You could get one recursive call to be a tail call, but rarely worth the complication
* Also beware the wrath of premature optimization – Favor clear, concise code – But do use less space/time if inputs may be large

## What is a tail-call?
The **"nothing left fo the caller to do"** intuition usually suffices
* If the result of `f x` is the **"immediate result"** for the enclosing function body, then `f x` is a tail call. But we can define "tail position" recursively
* Then a **tail call** is a function call in **tail position**

## Precise Definition
A tail call is a function call in tail position

* If an expression **is not** in tail position, then no subexpressions are
* In `fun f p = e`, the body `e` is in tail position
* If `if e1 then e2 else e3` is in tail position, then `e2` and `e3` are in tail position (but `e1` **is not**).
    * Similar for case-expressions
* If `let b1 … bn in e end` is in tail position, then `e` is in tail position (but the binding expressions **are not**)
* Function-call arguments `e1 e2` are not in tail position
* …

# First-Class Functions and Closures
## What is functional programming?
**"Functional programming"** can mean a few different things:

1) Avoiding mutation in most/all cases (done and ongoing)
2) Using functions as values (this unit)
3) Style encouraging recursion and recursive data structures
4) Style closer to mathematical definitions
5) Programming idioms using laziness (later topic, briefly)
6) Anything not OOP or C? (not a good definition)

Not sure a definition of **"functional language"** exists beyond:

"makes functional programming easy / the default / required"
## First-class functions
* **First-class functions:** Can use them wherever we use values
    * Functions are values too
    * Arguments, results, part of tuples, bound to variables, carried by datatype constructors or exceptions, ...
    
    Examples:
    ```
    fun double x = 2*x
    fun incr x = x+1
    val a_tuple = (double, incr, double(incr 7))
    val x = (#1 a_tuple) 3
    val y = (#2 a_tuple) 3
    val z = (#3 a_tuple)
    ```
    Types of bindings:
    ```
    val double = fn : int -> int
    val incr = fn : int -> int
    val a_tuple = (fn,fn,16) : (int -> int) * (int -> int) * int
    val x = 6 : int
    val y = 4 : int
    val z = 16 : int
    ```
* Most common use is as an argument / result of another function
    * Other function is called a higher-order function
    * Powerful way to factor out common functionality

## Function Closures
closure of a function f = (code of f) + (environment where f is defined)

* **Function closure:** Functions can use bindings from outside the function definition (in scope where function is defined)
    * Makes first-class functions much more powerful
    * Will get to this feature in a bit, after simpler examples
* Functions **"travel"** with their environment
* Distinction between terms first-class functions and function closures is not universally understood
    * Important conceptual distinction even if terms get muddled

## Functions as arguments
* Can pass one function as an argument to another.
```
fun f(g, ...) = ... g(...) ...
fun h1  ... = ...
fun h2  ... = ...

... f(h1, ...) ... f(h2, ...)...
```
* Good strategy for factoring out common code.
    * Replace N similar functions with calls to 1 function where you pass in N different (short) functions as arguments
### Example
Can reuse `n_times` rather than defining many similar functions
* Computes `f(f(...f(x))) where number of calls is n:
    ```
    fun n_times (f,n,x) =
    if n=0
    then x
    else f (n_times(f,n-1,x))

    fun double x = x + x

    fun increment x = x + 1

    val x1 = n_times(double,3,2)
    val x2 = n_times(increment,4,7)
    val x3 = n_times(tl,2,[4,8,12,16])

    fun double_n_times (n,x) = n_times(double,n,x)

    fun nth_tail (n,x) = n_times(tl,n,x)
    ```
    Types:
    ```
    val n_times = fn : ('a -> 'a) * int * 'a -> 'a
    val double = fn : int -> int
    val increment = fn : int -> int
    val x1 = 16 : int
    val x2 = 11 : int
    val x3 = [12,16] : int list
    val double_n_times = fn : int * int -> int
    val nth_tail = fn : int * 'a list -> 'a list
    END
    ```
## Relation to types
* Higher-order functions are often so "generic" and "reusable" that they have polymorphic types, i.e., types with type variables
* But there are higher-order functions that are not polymorphic
* And there are non-higher-order (first-order) functions that are polymorphic

## Types example
```
fun n_times (f,n,x) =
  if n=0
  then x
  else f (n_times(f,n-1,x))
```
Type:
```
val n_times : ('a -> 'a) * int * 'a -> 'a
```
* We could have created a simpler but less useful:
```
fun n_times (f:int , n:int, x:int) = 
  ... same as before...
```
```
val n_times = fn : int * int * int -> int
```
* Two of our examples instantiated `'a` with `int`
* One of our examples instantiated `'a` with `int list`
* This polymorphism makes `n_times` more useful
* Type is inferred based on how arguments are used (we will see this later)
    * Describes which types must be exactly something (e.g., `int`) and which can be anything but the same (e.g., `'a`)

May higher-order functions are polymorphic because they are so reusable that some types *"can be anything"*.

## Toward anonymous functions
Definitions unnecessarily at top-level are **poor style**:
```
fun trip x = 3*x
fun triple_n_times (n,x) = n_times(trip,n,x)
```
Better:
```
fun triple_n_times (n,x) =
  let
    fun trip y =
      3*y
     in
       n_times(trip,n,x)
  end
```
Best:
```
fun triple_n_times (f,x) =
  n_times(let fun trip y = 3*y in trip end,
          n, x)
```

## Anonymous functions
Even better best:
```
fun triple_n_times (f,x) =
  n_times((fn y => 3*y), n, x)
```
* `fn` not `fun`
* `=>` not `=`
* **no function name**, just an argument pattern

## Using anonymous functions
* Most common use: Argument to a higher-order function
    * No need to name, just pass the function
* Cannot use an anonymous function for a recursive function. No name for recursive call to function.

## Map
```
fun map (f,xs) =
  case xs of
      [] => []
    | x::xs' => (f x)::(map(f,xs'))
```
Type:
```
val map = fn : ('a -> 'b) * 'a list -> 'b list
```
## Filter
```
fun filter (f,xs) =
  case xs of
      [] => []
    | x::xs' => if f x
                then x::(filter(f,xs'))
                else filter(f,xs')
```
Type:
```
val filter = fn : ('a -> bool) * 'a list -> 'a list
```