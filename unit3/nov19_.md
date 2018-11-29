Example:
```ruby
class PolarPoint < Point
  # Interesting: by not calling super constructor, no x and y instance vars
  # In Java/C#/Smalltalk would just have unused x and y fields
  def initialize(r,theta)
    @r = r
    @theta = theta
  end
  def x
    @r * Math.cos(@theta)
  end
  def y
    @r * Math.sin(@theta)
  end
  def x= a
    b = y # avoids multiple calls to y method
    @theta = Math.atan2(b,a)
    @r = Math.sqrt(a*a + b*b)
    self
  end
  def y= b
    a = x # avoid multiple calls to y method
    @theta = Math.atan2(b,a)
    @r = Math.sqrt(a*a + b*b)
    self
  end
  def distFromOrigin # must override since inherited method does wrong thing
    @r
  end
  # inherited distFromOrigin2 already works!!
end
```

# Dynamic Dispatch
* Also known as late binding or virtual methods
* Call `self.m2()` in method `m1` defined in class `C` can resolve to a method `m2` defined in a subclass of `C`
* Most unique characteristics of OOP
  * Need to define the semantics of method lookup as carefilly as we defined variable lookup of our PLs

## Review: variable lookup
* **ML**: Look up variables in the appropriate environment
  * Lexical scope for closures
  * Field names (for records) are different: not variables
* **Racket**: Like ML plus `let`, `letrec`
* **Ruby**:
  * Local variables and blocks mostly like ML and Racket
  * But also have (similar to record fields)
    * instance variables
    * class variables
    * methods
    * look up in terms of `self`, which is special

## Using self
* `self` maps to some "current object
* Look up instance variable `@x` using object bound to `self`
* Look up class variables `@@x` using object bound to `self.class`
* Look up methods...

## Ruby method lookup
The semantics for methdo calls also known as message sends
```ruby
e0.m(e1, ..., en)
```
1) Evaluate `e0, e1, ..., en` to objects `obj0, obj1, ..., objn'
  * As usual, may involve looking up self, variables, fields, etc
2) Let `C` be the class of `obj0` (every object has a class)
3) If `m` is defined in `C`, pick that method, else recurse with the superclass of `C` unless `C` is already `Object`
  * If no `m` is found, call `method_missing` instead
    * Definition of `method_missing` in `Object` raises and error
4) Evaluate body of method picked:
  * With formal arguments bound to `obj1, ..., objn`
  * With `self` bound to `obj0`

# Static overloading
Same method name will always override another method in Ruby, not overload it.

## Simple example:
In Ruby (and other OOP languages), subclasses can change the behaviour of methods they do not override
```ruby
class A
  def even x
    print "in even"
    if x==0 then true else odd (x-1) end
  end
  def odd x
    print "in odd"
    if x==0 then false else even (x-1) end
  end
end
class B < A # improves odd in B objects
  def even x 
    print "better even"
    x % 2 == 0 
  end
end
class C < A # breaks odd in C objects
  def even x 
    print "bad even"
     false 
  end
end

a = A.new
puts "Printing A instance: " 
puts (a.odd 7).to_s
b = B.new
puts "Printing B instance: "
puts (b.odd 7).to_s
c = C.new
puts "Printing B instance " 
puts (c.odd 7).to_s
```
Outputs:
```
Printing A instance: 
in oddin evenin oddin evenin oddin evenin oddin eventrue

Printing B instance: 
in oddbetter eventrue

Printing C instance 
in oddbad evenfalse
```

# OOP vs Functional Decomposition
* In functional (and procedural) programming, break programs down into **functions that perform some operation**
* In object-oriented programming, break programs down into **classes that give behavior to some kind of data**

## The expression example
Well-known and compelling example of a common pattern:

* Expressions for a small language
* Different variants of expressions: ints, additions, negations, …
* Different operations to perform: eval, toString, hasZero, …

### Standard approach in OOP
* Define a class, with one abstract method for each operation
  * (No need to indicate abstract methods if dynamically typed)
* Define a subclass for each variant
* "fill out the grid" via one class per row
  * with one method implementation for each grid position
  * Can use a method in the superclass if there is a default for multiple entries in a column

Example:
```ruby
# Note: If Exp and Value are empty classes, we do not need them in a
# dynamically typed language, but they help show the structure and they
# can be useful places for code that applies to multiple subclasses.

class Exp
  # could put default implementations or helper methods here
end

class Value < Exp
  # this is overkill here, but is useful if you have multiple kinds of
  # /values/ in your language that can share methods that do not make sense 
  # for non-value expressions
end

class Int < Value
  attr_reader :i
  def initialize i
    @i = i
  end
  def eval # no argument because no environment
    self
  end
  def toString
    @i.to_s
  end
  def hasZero
    i==0
  end
end

class Negate < Exp
  attr_reader :e
  def initialize e
    @e = e
  end
  def eval
    Int.new(-e.eval.i) # error if e.eval has no i method
  end
  def toString
    "-(" + e.toString + ")"
  end
  def hasZero
    e.hasZero
  end
end

class Add < Exp
  attr_reader :e1, :e2
  def initialize(e1,e2)
    @e1 = e1
    @e2 = e2
  end
  def eval 
    Int.new(e1.eval.i + e2.eval.i) # error if e1.eval or e2.eval has no i method
  end
  def toString
    "(" + e1.toString + " + " + e2.toString + ")"
  end
  def hasZero
    e1.hasZero || e2.hasZero
  end
end
```