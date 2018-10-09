# Signatures
A signature is a type for a module
* Contents of module
* Seems similar to Interfaces?

Example:
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

### General structure
```
signature SIGNAME =
sig 
   types-for-bindings 
end
```
Ascribing a signature to a module:
```
structure MyModule :> SIGNAME =
struct 
   bindings 
end
```

## Hiding with functions
```
fun doubler x = x*2

fun doubler x = x+x

val y = 2
fun doubler x = x*y
```
The client is not concerned how `doubler` is implemented as they all have the same functionality.

For example, `MyMathLib.doubler` is simply unbound.
* so it cannot be used directly.
```
signature MATHLIB =
sig
  val fact : int -> int
  val half_pi : real
end
structure MyMathLib :> MATHLIB =
struct
  fun fact x = ...
  val half_pi = Math.pi / 2.0
  fun doubler x = x * 2
end
```

### A larger example
Consider a module that defines an Abstract Data Type (ADT)

Internally:
```
(5, 3) => 5/3
(1, 2) => 1/2
```

Externally:
```
Rational
Constructor
    make_frac(int, int) -> Rational
    add(Rational, Rational) -> Rational
    toString(Rational) -> string
```
Signature:
```
signature RATIONAL_A =
sig
   datatype rational = Whole of int | Frac of int*int
   exception BadFrac
   val make_frac : int * int -> rational
   val add : rational * rational -> rational
   val toString : rational -> string
end

structure Rational1 :> RATIONAL_A = ...
```

Invariants in internal implementation:
* all denominators > 0
* rationals kept in reduced form

Internal:
```
fun gcd (x, y) =
    if x = y
    then x
    else
        if x < y
        then gcd(x, y-x)
        else gcd(y, x)

fun reduce r = ...

fun make_frac (x, y) = ...

fun add (r1, r2) = ...

fun toString r = ...
```

If the client uses the exposed constructor instead of `make_frac` then our invariants get violated.

## Abstract types
In signature use `type foo`. This means that the type exists but clients do not know its implementation.
```
signature RATIONAL_B =
sig
  type rational
  exception BadFrac
  val make_frac : int * int -> rational
  val add : rational * rational -> rational
  val toString : rational -> string
end

structure Rational1 :> RATIONAL_B = ...
```
Nothing a client can do to violate invariants and properties:
* only way to make a first rational is `Rational1.make_frac
* after that can only use functions exposed
* hides constructors and patterns
* can still pass around functions

Add back functionality of `Whole`.
```
signature RATIONAL_C =
sig
  type rational
  exception BadFrac
  val Whole : int -> rational
  val make_frac : int * int -> rational
  val add : rational * rational -> rational
  val toString : rational -> string
end
```

## Signature Matching
`structure Foo :> BAR` is allowed if:
* every non-ADT in `BAR` is also in `Foo`
    * can be a datatype or type synonym
* every val-binding in `BAR` is provided in `Foo`, possibly with a more generic and/or less abstract internal type
* every exception in `BAR` is provided in `Foo`
`Foo` can always have more bindings than `BAR`.

## Equivalent Implementations
A key purpose of abstraction is to allow *different implementations* to be *equivalent*.
* Client cannot tell which you are using
* Can improve/replace/choose implementation later

Example: `structure Rational2` does not keep rationals in reduced form, instead reducing them "at last moment" in `toString`.

Given a signature with an abstract type, different structures can:
* have that signature
* implement the abstract type differently

Such structures may or may not be equivalent.

Cannot mix module bindings.
```
Rational1.toString(Rational2.make_frac(9,6))
Rational3.toString(Rational2.make_frac(9,6))
```
This will result in a type error.

## Function equivalence
When can we say that two functions are equal?

Two functions are equivalent if they have the same "observable behaviour" no matter how they are used anywhere in the program.

It is easier to be equivalent if there are fewer arguments and we are avoiding side effects.

Example:
These are equivalent
```
fun f x = x + x

val y = 2
fun x = y * 2
```
These are not equivalent
```
fun g (f, x) =
    (f x) + (f x)

val y = 2
fun g (f, x) =
    y * (f x)
```
For example, if `f` prints.

This is why we work towards *pure* functions.

## Standard Equivalence
* Syntactic sugar should always be equivalent
* Renaming variables
* Unnecessary function wrapping

## Equivalence of Performace
* Asymptotic performace (BigO)
* Systems performace