# Intro to Ruby
* Pure Object-oriented
* Class-based
  * Every object belongs to a class
* Dynamically typed
* Convinient reflection
  * Run-time inspection of objects

Basic example:
```ruby
class Hello
  def func
    puts "Hello World"
  end
end

x = Hello.new
x.func
```

In Ruby:
* All values are references to objects
* Objects communicate via method calls, also known as messages
* Each object has its own **(private)** state
* An object's class determines the object's behavior
  * how it handles method calls
  * class contains method definitions

## Defining classes and methods
Example:
```ruby
class Name
  def method_name1 method_args1
    expression1
  end
  def method_name2 method_args2
    expression2
  end
  ...
end
```
* First character of class **must** be capitalized
* Methods return the last expression within them
  * also has an explicit return statement
* Linebreaks often required, indentation alsways only style

Example:
```ruby
class A
  def m1
    34
  end

  def m2 (x,y)
    z = 7
    if x > y 
      false
    else
      x + y * z
    end
  end

end

class B
  def m1
    4
  end

  def m3 x
    x.abs * 2 + self.m1
  end
end
```

## Creating and using an object
* `ClassName.new` creates a new object whose class is `ClassName`
* `e.m` evaluates `e` to an object and then calls its `m` method
  * also known as *"sends the m message"*
  * can also write `e.m()`
* Methods can take arguments, called like `e.m(e1, ..., en)`
  * parentheses optional but recommended
* `self` similare to `this` in Java
* can be created via contructor (default or declared) using `Class.new`
  * or via method invocation

## Variables
* Methods can use local variables
  * names start with a letter
  * scope is method body
* No need to declare, just assign
  * can only use variables that have a valid value
* Variables are mutable, `x = e`
* Variables also allowed at **global-level**
* `@@x` before a variable `x` is class state
  * like a static variable??
* `@x` object state
* `x` function state

## Self
* Refers to the *current* object
  * the object whos method is executing
* Can call another method in same object with `self.m()`
  * syntactic sugar `m()`
* Can also pass/return/store *the whole object* with just `self`

Example: cascading
```ruby
class C
  def m1
    print "hi "
    self
  end
  def m2
    print "bye "
    self
  end
  def m3
    print "\n"
    self
  end
end

c = C.new
c.m1
c.m1.m2
c.m1.m2.m3.m2.m3
```

## Objects have state
* an object's state persists
  * can grow and change from the time object is created
* State **only directly accessible** from object's methods
* State consists of **instance variables** (fields)
  * `@x`

## Aliasing
* Creating an object returns a reference to a new object
  * Different state from every other object
* Variable assignment creates an alias

## Initialization
* A method named `initialize` is special
  * it is called on a new object before `new` returns
  * arguments to `new` are passed to `initialize`
  * similar to constructors in Java/C#/etc
* Usually good style to create instance variables in `initialize`
* Just a convention
* Different instances of the same class can have different instance variables

Example:
```ruby
class A 
  # uses initialize method, which is better than m1
  # initialize can take arguments too (here providing defaults)
  def initialize(f=0)
    @val = f
  end

  def m2 x
    @val += x
  end

  def x
    @val
  end

end

x = A.new   # new object
y = A.new   # new object
z = x       # aliases x to z
```

## Class variables
* There is also state shared by the entire class
* Shared by (and only accessible to) all instances of the class
  * Like Java static fields
* Called *class variables*
  * `@@x`

## Class constants and methods
* Class constants
  * Start with a capital letter
  * should not be mutated
  * visible outside class `C` as `C::Name` (unlike class variables)
* Class methods
  * Similar to Java static methods
  * use `self.name` in method declaration
    ```ruby
    def self.method_name (args)
    ...
    end
    ```
  * use with the class name `C.method_name(args)`
  * part of the class, not a particular instance of it

Example:
```ruby
class F
  # we now add in a class-variable, class-constant, and class-method

  Age = 23 # constant

  def self.reset_gvar
    @@gvar = 0
  end

  def initialize(f=0)
    @var = f
  end

  def m2 x
    @var += x
    @@gvar += 1
  end

  def var
    @var
  end

  def gvar
    @@gvar
  end
end

d = F.new 17
d.m2 5
e = F.new
e.m2 6
d.var
d.gvar        #  error: @@gvar uninitialize
F::reset_gbar  #  initializes @@gvar to 0
```

## Object state is private
* must access through methods (like getters)
  ```ruby
  def get_x
    @x
  end

  def set_x y
    @x = y
  end
  ```
  ```ruby
  def x
    @x
  end

  def x= y
    @x = y
  end
  ```
Because defining getters/setters is so common, there is shorthand for it in class definitions

* Define just getters: `attr_reader :x, :y, …`
* Define getters and setters: `attr_accessor :x, :x, …`
* Define just setters: `attr_writter :x, :x, …`

Example:
```ruby
class Person
  def initialize(name)
    @name = name
  end

  def name 
    @name
  end

  def name=(value)
    @name = value
  end
end
```
vs
```ruby
class Person
  attr_reader :name
  attr_writer :name
  def initialize(name)
    @name = name
  end
end
```
vs
```ruby
class Person
  attr_accessor :name
  def initialize(name)
    @name = name
  end
end
```

## Method visibility
* `private` - object
* `protected` - class and subclasses
* `public` - all code
* Methods are `public` by default
```ruby
class MyClass =
# by default methods public
  ...
protected
# now methods will be protected until
# next visibility keyword
  ...
public
  ...
private
  ...
end
```

If m is private, then you can only call it via m or m(args)
* As usual, this is shorthand for self.m …
* But for private methods, only the shorthand is allowed

Example:
```ruby
class MyRational

  def initialize(num,den=1) # second argument has a default
    if den == 0
      raise "MyRational received an inappropriate argument"
    elsif den < 0 # notice non-english word elsif
      @num = - num # fields created when you assign to them
      @den = - den
    else
      @num = num # semicolons optional to separate expressions on different lines
      @den = den
    end
    reduce # i.e., self.reduce() but private so must write reduce or reduce()
  end

  def to_s 
    ans = @num.to_s
    if @den != 1 # everything true except false _and_ nil objects
      ans += "/"
      ans += @den.to_s 
    end
    ans
  end

  def to_s2 # using some unimportant syntax and a slightly different algorithm
    dens = ""
    dens = "/" + @den.to_s if @den != 1
    @num.to_s + dens
  end

  def to_s3 # using things like Racket's quasiquote and unquote
    "#{@num}#{if @den==1 then "" else "/" + @den.to_s end}"
  end

  def add! r # mutate self in-place , yes, ! can be part of a method name,
             #        but only at the end, and only once: ?, !, =
    a = r.num # only works b/c of protected methods below
    b = r.den # only works b/c of protected methods below
    c = @num
    d = @den
    @num = (a * d) + (b * c)
    @den = b * d
    reduce
    self # convenient for stringing calls
  end

  # a functional addition, so we can write r1.+ r2 to make a new rational
  # and built-in syntactic sugar will work: can write r1 + r2
  def + r
    ans = MyRational.new(@num,@den)
    ans.add! r
    ans
  end

protected  
  # there is very common sugar for this (attr_reader)
  # the better way:
  # attr_reader :num, :den
  # protected :num, :den
  # we do not want these methods public, but we cannot make them private
  # because of the add! method above
  def num
    @num
  end
  def den
    @den
  end

private
  def gcd(x,y) # recursive method calls work as expected
    if x == y
      x
    elsif x < y
      gcd(x,y-x)
    else
      gcd(y,x)
    end
  end

  def reduce
    if @num == 0
      @den = 1
    else
      d = gcd(@num.abs, @den) # notice method call on number
      @num = @num / d
      @den = @den / d
    end
  end
end

# can have a top-level method (just part of Object class) for testing, etc.
def use_rationals
  r1 = MyRational.new(3,4)
  r2 = r1 + r1 + MyRational.new(-5,2)
  puts r2.to_s
  (r2.add! r1).add! (MyRational.new(1,-4))
  puts r2.to_s
  puts r2.to_s2
  puts r2.to_s3
end
```

## Pure OOP
* Numbers have methods like `+`, `abs`, `nonzero?`, etc.
* `nil` is an object used as a "nothing" object
  * Like `null` in Java/C#/C++ except it is an object
  * Every object has a `nil?` method, where `nil` returns `true` for it
  * Note: `nil` and `false` are "false", everything else is "true"
* Strings also have a `+` method
  * String concatenation
  * Example: `"hello" + 3.to_s`
  * same as `"hello".+(3.to_s)`

## All code is methods
* All methods you define are part of a class
* Top-level methods (in file or REPL) just added to `Object` * class
* Subclassing discussion coming later, but:
  * Since all classes you define are subclasses of `Object`, all inherit the top-level methods
  * So you can call these methods anywhere in the program
  * Unless a class overrides (roughly-not-exactly, shadows) it by defining a method with the same name

## Reflection and exploratory programming
* All objects also have methods like:
  * `methods`
  * `class`
* Can use at run-time to query "what an object can do" and respond accordingly
  * Called reflection
  * Also useful in the REPL to explore what methods are available
  * May be quicker than consulting full documentation
  * Another example of "just objects and method calls"

## Changing classes
* Ruby programs (or the REPL) can add/change/replace methods while a program is running
* Breaks abstractions and makes programs very difficult to analyze, but it does have plausible uses
  * Simple example: Add a useful helper method to a class you did not define
    * Controversial in large programs, but may be useful
* For us: Helps re-enforce "the rules of OOP"
  * Every object has a class
  * A class determines its instances' behavior