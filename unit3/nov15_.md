# Duck Typing
Example:
```ruby
def mirror_update pt
  pt.x = pt.x * (-1)
end
```
Natural thought: "Takes a Point object (definition not shown here), negates the `x` value"

Closer: "Tales anything with getter and setter methods for `@x` instance variable and multiplies the `x` field by `-1`"

Closer: "Takes anything with the methods `x=` and `x` and calls `x=` with the result of multiplying `x` and `-1`"

Duck typing: "Takes anything with method `x=` and `x` where result of `x` has a `*` method that can take `-1`. Sends result of calling `x` the `*` message with `-1` and sends that result to `x=`.

* Plus: Maybe `mirror_update` is useful for classes we did not anticipate.
* Minus: If someone does abuse duck typing here, then we cannot change the implementation of `mirror_update`.

Better example:
```ruby
def double x
  x + x
end
```

# Ruby Arrays
* Lots of special syntax and many provided methods for the Array class
* Can hold any number of other objects, indexed by number
  * Get via `a[i]`
  * Set via `a[i] = e`
* Compared to arrays in many other languages
  * More flexible and dynamic
  * Fewer operations are errors
  * Less efficient
* "The standard collection" like lists were in ML and Racket

Array Examples:
```ruby
a = [3,2,7,9]
a[2]
a[0]
a[4]
a.size
a[-1]
a[-2]
a[1] = 6
a
a[6] = 14
a
a[5]
a.size

a[3] = "hi"

b = a + [true,false]
c = [3,2,3] | [1,2,3]

# array make fine tuples

triple = [false, "hi", a[0] + 4]
triple[2]

# arrays can also have initial size chosen at run-time
# (and as we saw can grow later -- and shrink)
x = if a[1] < a[0] then 10 else 20 end
y = Array.new(x)

# better: initialized with a block (coming soon)
z = Array.new(x) { 0 }
w = Array.new(x) {|i| -i }

# stacks
a
a.push 5
a.push 7
a.pop
a.pop
a.pop

# queues (from either end)

a.push 11
a.shift
a.shift
a.unshift 14

# aliasing

d = a
e = a + []
d[0]
a[0] = 6
d[0]
e[0]

# slices 

f = [2,4,6,8,10,12,14]
f[2,4]
f.slice(2,2)
f.slice(-2,2)
f[2,4] = [1,1]

[1,3,4,12].each {|i| puts (i * i)}
```

## Blocks
Almost just closures?
* Easy way to pass anonymous functions to methods for all the usual reasons
* Blocks can take 0 or more arguments
* Blocks use lexical scope: block body uses environment where block was defines

Examples:
```ruby
3.times {  puts "hello" }

[4,6,8].each {   puts "world" }

i = 7

[4,6,8].each {|x|
  if i > x then
    puts (x+1)
  end
}

[4,6,8].each do |x|
   puts "Value of x " + x.to_s
end
```

### Some strange things about blocks
* Can pass 0 or 1 block with any message
  * Callee might ignore it
  * Callee might give an error if you do not send one
  * Callee might do different things if you do/don't send one
    * also number-of-block-arguments can matter
* Just put the block "next to" the "other" arguments (if any)
  * Syntax: `{e}, {|x| e}, {|x,y| e}`, etc. (plus variations)
    * Can also replace `{ }` with `do` and `end`
* Often preferred for blocks > 1 line

### Blocks everywhere
* Rampant use of great block-taking methods in standard library
* Ruby has loops but very rarely used
  * Can write `(0...i).each {|j| e}`, but often better options

Examples:
```ruby
a = Array.new(5) {|i| 4*(i+1)}
a.each { puts "hi" }
a.each {|x| puts (x * 2) }
a.map {|x| x * 2 } #synonym: collect
a.any? {|x| x > 7 }
a.all? {|x| x > 7 }
a.inject(0) {|acc,elt| acc+elt }
a.select {|x| x > 7 } #non-synonym: filter
```

### More strangeness
* Callee does not give a name to the (potential) block argument
* Instead, just calls it with `yield` or `yield(args)`

### Blocks are "second-class"
All a method can do with a block is `yield`to it
* Cannot
  * return it
  * store it
* But can turn blocks into real closures
* Closures are instances of class `Proc`
  * Called with method `call`

Several ways to make `Proc` objects
* one way: method `lambda` of `Object` takes a block and returns the corresponding `Proc`

Example:
```ruby
a = [3,5,7,9]

# Blocks are fine for applying to array elements
b = a.map {|x| x+1 }
i = b.count {|x| x>=6 }

# but for an array of closures, need Proc onjects
c = a.map {|x| lambda {|y| x>=y}}
c[2].call 17
j = c.count {|x| x.call(5) }
```

## Hashes
* Keys can be anything
* No natural ordering like numeric indices
* Different syntax to make them Like a dynamic record with anything for field names
* Often pass a hash rather than many arguments

## Ranges
Ranges like arrays of contiguous numbers but
* more efficiently represented, so large ranges fine

Good style to
* use ranges when you can
* use hashes when non-numeric keys better represent data

## Similar methods between data structures
Array, hashes, and ranges all have some methods others don't
* keys and values

But also have many of the same methods, particularly iterators
* great for duck typing

Example:
```ruby
def myclass a
  a.count {|x| x*x < 50}
end
myclass [3,5,7,9]
myclass (3..9)
```

# Subclasses, inheritance, and overriding
## Subclassing
A class definition always has a *superclass*. (Will be `Object` if not specified)
```ruby
class ColorPoint < Point
  ...
```
The superclass affects the class definition
* class inherits all method definitions from superclass
* class can override method definitions
* CANNOT inherit fields since all objects create instance variables by assigning to them

Example:
```ruby
class Point
  attr_accessor :x, :y
  def initialize(x,y)
    @x = x
    @y = y
  end
  def distFromOrigin     # direct field access
    Math.sqrt(@x*@x + @y*@y)
  end
  def distFromOrigin2
    # use getters
    Math.sqrt(x*x + y*y)
  end
end

class ColorPoint < Point
  attr_accessor :color
  def initialize(x,y,c)
    super(x,y)
    @color = c
  end
end
```

### Every object has a class
```ruby
p = Point.new(0,0)
cp = ColorPoint.new(0,0,"red")
p.class                            # Point
p.class.superclass                 # Object
cp.class                           # ColorPoint
cp.class.superclass                # Point
cp.class.superclass.superclass     # Object
cp.is_a? Point                     # true
cp.instance_of? Point              # false
cp.is_a? ColorPoint                # true
cp.instance_of? ColorPoint         # true
```

Using these methods is non-OOP style

Here subclassing is a good choice
```ruby
class ColorPoint < Point
  attr_accessor :color
  def initialize(x,y,c)
    super(x,y)
    @color = c
  end
end
```

### Why subclass...
* Often OOP programmers overuse subclassing
* But for `ColorPoint` subclassing makes sense:
  * less work
  * can use a `ColorPoint` wherever code expects a `Point`

## Overriding
* A `ThreeDPoint` is more interesting than `ColorPoint` because it overrides `distFromOrigin` and `distFromOrigin2`
* Gets code reuse, but highly disputable if it is appropriate to say a `ThreeDPoint` "is a" `Point`
* Still just avoiding copy/paste

Example:
```ruby
class ThreeDPoint < Point
  attr_accessor :z

  def initialize(x,y,z)
    super(x,y)
    @z = z
  end
  def distFromOrigin
    d = super
    Math.sqrt(d * d + @z * @z)
  end
  def distFromOrigin2
    d = super
    Math.sqrt(d * d + z * z)
  end
end
```