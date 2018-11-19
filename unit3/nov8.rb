class Hello
  def func
    puts "Hello World"
  end
end

x = Hello.new
x.func


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
    # @@gvar += 1
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
# d.gvar        #  error: @@gvar uninitialize
# F::reset_gbar  #  initializes @@gvar to 0