# Anonymous Functions
## Fold
Like sum, but for any types.
`fold(a' list, fn, a')`

## Lexical scope
* functions will run in the environment where they were defined, not where they are called.

## Operators
```
fun op times (x, y) = x * y
val z = 3 times 4
```
* The `op` keyword tells sml that this function is infix.

## Filter
```
fun filter (f,xs) =
  case xs of
      [] => []
    | x::xs' => if f x
                then x::(filter(f,xs'))
                else filter(f,xs')
```

## Generalizing
* Our examples of first-class functions so far have all:
    * Taken one function as an argument to another function
    * Processed a number or a list
* But first-class functions are useful anywhere for any kind of data
    * Can pass several functions as arguments
    * Can put functions in data structures (tuples, lists, etc.)
    * Can **return functions as results**
    * Can write higher-order functions that traverse your own data structures
* Useful whenever you want to **abstract** over "**what to compute with**"
    * No new language features

## Returning Functions
Example:
```
fun double_or_triple f =
    if f 7
    then fn x => 2*x
    else fn x => 3*x
```
Has type:
```
val double_or_triple = fn : (int -> bool) -> int -> int
```
never prints unnecessary parentheses and `t1->t2->t3->t4` means `t1->(t2->(t3->t4))`

Example of higher order predicate:
```
fun true_of_all_constants(f,e) =
  case e of
      Constant i => f i
    | Negate e1 => true_of_all_constants(f,e1)
    | Add(e1,e2) => true_of_all_constants(f,e1)
                    andalso true_of_all_constants(f,e2)
    | Multiply(e1,e2) => true_of_all_constants(f,e1)
                         andalso true_of_all_constants(f,e2)
```
of type:
```
(int -> bool) * exp -> bool
```
And call it:
```
true_of_all_constants((fn x => x mod 2 = 0), e)
```

## Lexical Scope
* We know function bodies can use any bindings in scope
* But now that functions can be passed around:
    * **In scope where?**
    * Answer:
        * Where the function **was defined**
        * **not where it was called**
* This semantics is called **lexical scope**
* There are lots of good reasons for this semantics (why)
    * Discussed after explaining what the semantics is (what)
    * Later in course: implementing it (how)
* Must "**get this**" for homework, exams, and competent programming

## Lexical Scope Example:
```
1: val x = 1 
2: fun f y = x + y
3: val x = 2
4: val y = 3
5: val z = f(x+y)
```
* Line 2 defines a function that, when called, evaluates body `x+y` in environment where `x` maps to `1` and `y` maps to the argument
* Call on line 5:
    * Looks up `f` to get the function defined on line 2
    * Evaluates `x+y` in current environment, producing `5`
    * Calls the function with `5`, which evaluates the body in the old environment, producing `6`
Types:
```
val x = <hidden-value> : int
val f = fn : int -> int
val x = 2 : int
val y = 3 : int
val z = 6 : int
```

## Closures
How can functions be evaluated in old environments that aren't around anymore?
* The language implementation keeps them around as necessary

Can define the semantics of functions as follows:
* A function value has two parts
    * The code (obviously)
    * The environment that was current when the function was defined
* This is a "pair" but unlike ML pairs, you cannot access the pieces
    * All you can do is call this "pair"
* This pair is called a function closure
* A call evaluates the code part in the environment part
    * extended with the function argument

### Example:
```
1: val x = 1 
2: fun f y = x + y
3: val x = 2
4: val y = 3
5: val z = f(x+y)
```
* Line 2 creates a closure and binds `f` to it:
    * Code:
        * "take `y` and have body `x+y`"
    * Environment:
        * "`x` maps to `1`"
        * (Plus whatever else is in scope, including f for recursion)
* Line 5 calls the closure defined in line 2 with `5`
* So body evaluated in environment:
    * "`x` maps to `1`" *extended with* "`y` maps to `5`"

### The rule stays the same
**A function body is evaluated in the environment where the function was defined (created)**
* Extended with the function argument
* Nothing changes to this rule when we take and return functions
    * But "the environment" may involve nested let-expressions,
        * not just the top-level sequence of bindings
* Makes first-class functions **much more powerful**
    * Even if may seem counterintuitive at first

## Why Lexical Scope
* **Lexical scope**: use environment where function is defined
* **Dynamic scope**: use environment where function is called

Decades ago, both might have been considered reasonable, but now we know lexical scope makes much more sense

1) Function meaning does not depend on variable names used
2) Functions can be type-checked and reasoned about where defined
3) Closures can easily store the data (environment) they need

```
fun greaterThanX x = 
  fn y => y > x

fun filter(f, xs) = 
  case xs of
      [] => []
    | x::xs => if f x
               then x::(filter(f,xs))
               else filter(f,xs)

fun noNegatives xs = 
  filter(greaterThanX ~1, xs)

fun allGreater (xs,n) =
  filter(fn x => x > n, xs)
```

### Does dynamic scope exist?
* Lexical scope for variables is definitely the right default
    * Very common across languages
* Dynamic scope is occasionally convenient in some situations
    * So some languages (e.g., Racket) have special ways to do it
    * But most do not bother
* If you squint some, exception handling is more like dynamic scope:
    * `raise e` transfers control to the current innermost handler
    * Does not have to be syntactically inside a handle expression (and usually is not)

## When things evaluate
Things we know:
* A **function body** is **not evaluated** when the function is **defined**
* A **function body** **is evaluated** every time the function is **called**
* A **variable binding evaluates** its expression when the **binding is evaluated** (defined)
    * not every time the variable is used

With closures, this means we can avoid repeating computations that do not depend on function arguments
* Not so worried about performance, but good example to emphasize the semantics of functions

### Recomputation
```
fun allShorterThan1 (xs,s) =
  filter(fn x => String.size x < String.size s,
         xs)

fun allShorterThan2 (xs,s) =
  let
    val i = String.size s
  in
    filter(fn x => String.size x < i, xs)
  end
```
* The first one computes `String.size` once per element of `xs`
* The second one computes `String.size s` once per list
    * Nothing new here: let-bindings are evaluated when encountered and function bodies evaluated when called

## Fold
Accumulates an answer by repeatedly applying f to answer so far
```
fold(f,acc,[x1,x2,x3,x4])
```
computes:
```
f(f(f(f(acc,x1),x2),x3),x4)
```
Definition:
```
fun fold (f,acc,xs) =
  case xs of
      [] => acc
    | x::xs => fold(f, f(acc,x), xs)
```
This version "**folds left**"; another version "**folds right**"