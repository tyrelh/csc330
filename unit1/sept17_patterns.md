## In-order Tree Traversal
```
fun in_order(theTree: tree) =
    case theTree of
        emptyTree           => []
        | Tree(value, l, r) =>
            in_order(l) @ [value] @ in_order(r)
```
## Expression Trees
```
datatype exp = Constant of int
   | Negate of exp
   | Add    of exp * exp
   | Multiply of exp * exp
```
### Recursive Evaluation
```
fun eval e =
   case e of
      Constant i      => i
    | Negate e2       => ~(eval e2)
    | Add(e1,e2)      => (eval e1) + (eval e2)
    | Multiply(e1,e2) => (eval e1) * (eval e2)
```
## Datatype Bindings
```
case e of p1 => e1 
        | p2 => e2 
        | ... 
        | pn => en
```
*"|" is exclusive or*

## Recursive Datatypes
```
datatype my_int_list = Empty
                      | Cons of int * my_int_list

val x = Cons(4,Cons(23,Cons(2008,Empty)))

fun append_my_list (xs,ys) =
   case xs of
        Empty => ys
     |  Cons(x,xs') => Cons(x, append_my_list(xs',ys))
```

## Options are Datatypes
* NONE and SOME are constructors, not just functions
* So use pattern-matching not isSome and valOf
```
fun inc_or_zero intoption =
    case intoption of
          NONE   => 0
        | SOME i => i+1
```

## Lists are Datatypes
Avoid using hd, tl, *null
* [] and :: are constructors too
* (strange syntax, particularly infix)
```
fun sum_list xs =
  case xs of
      [] => 0
    | x::xs' => x + sum_list xs'
                             
fun append (xs,ys) =
  case xs of
      [] => ys
    | x::xs' => x :: append(xs',ys)
```
Instead of using
```
let
    x = hd list
in
    ...
```
can use
```
case list of
    a::b => ... (* a is head, b is tail *)
```

**Do not use isSome, valOf, null, hd, tl on Homework 2**

## Each-of Types
* The pattern (x1,…,xn) matches the tuple value (v1,…,vn)
* The pattern {f1=x1, …, fn=xn} matches the record value {f1=v1, …, fn=vn} (and fields can be reordered)
```
fun sum_triple triple =
   case triple of
      (x, y, z) => x + y + z

fun full_name r =
   case r of {first=x, middle=y, last=z} => 
      x ^ " " ^ y ^ " " ^ z
```
Remember: poor style to use one-branch case statements.

**Encouraged for A2 to not declare types. Use type-inference.**

If ```y``` is removed from the return above, the input of ```y``` can be any type. Like: ```int * `a * int```.

### Better Example
```
fun sum_triple triple =
  let 
    val (x, y, z) = triple
  in
    x + y + z
  end
      
fun full_name r =
  let val {first=x, middle=y, last=z} = r
  in
    x ^ " " ^ y ^ " " ^ z
  end
```

### Function-argument Patterns
A function argument can also be a pattern
```
fun sum_triple (x, y, z) =
  x + y + z

fun full_name {first=x, middle=y, last=z} =
  x ^ " " ^ y ^ " " ^ z
```

**Don't use # character in A2.**

In ML, functions always only take one param. Multiple params are pattern matched from the single given param. No params is the unit param ().

## Nested Patterns
We can nest patterns as deep as we want – Just like we can nest expressions as deep as we want – Often avoids hard-to-read, wordy nested case expressions

### zip/unzip 3 lists
```
fun zip3 lists =
  case lists of
      ([],[],[]) => []
    | (hd1::tl1,hd2::tl2,hd3::tl3) =>
      (hd1,hd2,hd3)::zip3(tl1,tl2,tl3)
    | _ => raise ListLengthMismatch
                 
fun unzip3 triples =
  case triples of
      [] => ([],[],[])
    | (a,b,c)::tail =>
        let 
            val (l1, l2, l3) = unzip3 tail
        in
            (a::l1,b::l2,c::l3)
        end
```
Remember: _ matches any pattern.

### Examples of Patterns
Pattern matches all lists with >= 3 elements
```
a::b::c::d
```
Pattern matches all lists with exactly 3 elements:
```
a::b::c::[]
```
Pattern matches all non-empty lists of pairs of pairs
```
((a,b),(c,d))::e
```

# Exceptions

An exception binding introduces a new kind of exception
```
exception MyFirstException
exception MySecondException of int * int
```
The raise primitive raises (a.k.a. throws) an exception
```
raise MyFirstException
raise (MySecondException(7,9))
```
A handle expression can handle (a.k.a. catch) an exception
* If doesn't match, exception continues to propagate
```
e1 handle MyFirstException => e2
e1 handle MySecondException(x,y) => e2
```

Exceptions are a lot like datatype constructors.

* Declaring an exception adds a constructor for type *exn*
* Can pass values of *exn* anywhere (e.g., function arguments - Not too common to do this but can be useful
* *handle* can have multiple branches with patterns for type exn

# Recursion
Should now be comfortable with recursion:

* No harder than using a loop
* Often much easier than a loop – When processing a tree (e.g., evaluate an arithmetic expression, finding a value) – Examples like appending lists – Avoids mutation even for local variables
* Now: – How to reason about efficiency of recursion – The importance of tail recursion – Using an accumulator to achieve tail recursion

### Call-stacks
While a program runs, there is a call stack of function calls that have started but not yet returned

– Calling a function *f* pushes an instance of f on the stack (a *frame*) – When a call to *f* finishes, it is popped from the stack

These *stack-frames* store information: like the value of local variables and "what is left to do" in the function

Due to recursion, multiple stack-frames may be calls to the same function

Ex:
```
fun fact n = if n=0 then 1 else n*fact(n-1)
val x = fact 3
```
Better way (using an accumulator):
```
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
ML recognizes *tail-recursion* and will use optimizations.