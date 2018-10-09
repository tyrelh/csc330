# Sept 13 CSC 330

## Recursion in SML
use a val in let to to the recursive call, then simply use the value in the actual function, instead of making multiple recursive calls.

## Typing in languages
static typing knows the types at compile time
dynamic typing knows the types at run time

## Aspects of languages
1) **Syntax**
2) **Semantics**
3) **Idioms**
4) Libraries
5) Tools
    a) Compiler
    b) IDE
    c) Debugger
    d) Lint
    e) Package Manager

## Building bigger types
Already know:
    Have various base types like int bool unit char
    Ways to build (nested) compound types:
        tuples,
        lists,
        options
    more ways to build compound types:
        "Each of": A t value contains values of each of t1 t2 … tn
        "One of": A t value contains values of one of t1 t2 … tn
        "Self reference": A t value can refer to other t values

options have a **value** or **NONE**.
lists contain **values** or other **lists** or **NONE**.

Another way to build each-of types in ML
    Records have named fields
    Connection to tuples and idea of syntactic sugar
A way to build and use our own one-of types in ML
    For example, a type that contains an int or a string
    Will lead to pattern-matching, one of ML's coolest and strangest features
Later in course:
    How OOP does one-of types
    Key contrast with procedural and functional programming

## Records
```
val y = {f1=1, f2="abc", f3=4.0}
    {name=value, name=value, name=value}
```
think of it like an object or struct, not a dict or hash map.

retrieve a value using #name:
```
(#f1 y) -> 1
```

tuples are syntactic sugar for records with fields named 1, 2, ... n

## Syntactic Sugar

**andalso** and **orelse** vs **if then else**

cannot implement **if then else** with a function since all three expressions will be executed in the function call

pure functions have no side effects

## Datatype Bindings

```
datatype mytype = TwoInts of int * int | Str of string | Pizza
```

Adds a new type mytype to the environment
Adds constructors to the environment: TwoInts, Str, and Pizza

A constructor is (among other things), a function that makes values of the new type (or is a value of the new type):

```
TwoInts: int * int -> mytype
Str    : string -> mytype
Pizza  : mytype
```

## Pattern Matching

```
fun f x = (* f has type mytype -> int *)
    case x of
        Pizza => 3
        | TwoInts(i1,i2) => i1+i2
        | Str s => String.size s
```

* A multi-branch conditional to pick branch based on variant
* Extracts data and binds to variables local to that branch
* **Type-checking:**
all branches must have same type
* **Evaluation:**
evaluate between case… of and the right branch

In general the syntax is:

```
case e0
    p1 => e1
    | p2 => e2
    ...
    | pn => en
```

Why this way is better?

1) You cannot forget a case:
   * inexhaustive pattern-match warning
2) You cannot duplicate a case:
    * a type-checking error
3) You will not forget to test the variant correctly and get an exception
    * like hd []
4) Pattern-matching can be generalized and made more powerful, leading to elegant and concise code

## Useful examples of Pattern Matching

* Enumerations, including carrying other data other data:
```
datatype suit =
    Club |
    Diamond |
    Heart |
    Spade
datatype card_value =
    Jack |
    Queen |
    King |
    Ace |
    Num of int l
datatype card = suit * card_value
```
* Alternate ways of identifying real-world things/people:
```
datatype id =
    StudentNum of int |
    Name of string * (string option) * string
```

## Expression Trees

```
datatype exp = Constant of int
   | Negate of exp
   | Add    of exp * exp
   | Multiply of exp * exp
```

```
Add (Constant (10+9), Negate (Constant 4))
```

## Recursion of Expression Trees

```
fun eval e =
   case e of
      Constant i      => i
    | Negate e2       => ~(eval e2)
    | Add(e1,e2)      => (eval e1) + (eval e2)
    | Multiply(e1,e2) => (eval e1) * (eval e2)
```