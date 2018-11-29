# Tyrel Hiebert

# a little language for 2D geometry objects
# each subclass of GeometryExpression, including subclasses of GeometryValue,
#  needs to respond to messages preprocess_prog and eval_prog
#
# each subclass of GeometryValue additionally needs:
#   * shift
#   * intersect, which uses the double-dispatch pattern
#   * intersectPoint, intersectLine, and intersectVerticalLine for 
#       for being called by intersect of appropriate clases and doing
#       the correct intersection calculuation
#   * (We would need intersectNoPoints and intersectLineSegment, but these
#      are provided by GeometryValue and should not be overridden.)
#   *  intersectWithSegmentAsLineResult, which is used by 
#      intersectLineSegment as described in the assignment
#
# you can define other helper methods, but will not find much need to
# Note: geometry objects should be immutable: assign to fields only during
#       object construction
# Note: For eval_prog, represent environments as arrays of 2-element arrays
# as described in the assignment

class GeometryExpression  
  # do *not* change this class definition
  Epsilon = 0.00001
end


class GeometryValue 
  # do *not* change methods in this class definition
  # you can add methods if you wish
  private
  # some helper methods that may be generally useful
  def real_close(r1,r2) 
      (r1 - r2).abs < GeometryExpression::Epsilon
  end
  def real_close_point(x1,y1,x2,y2) 
      real_close(x1,x2) && real_close(y1,y2)
  end
  # two_points_to_line could return a Line or a VerticalLine
  def two_points_to_line(x1,y1,x2,y2) 
      if real_close(x1,x2)
        VerticalLine.new x1
      else
        m = (y2 - y1).to_f / (x2 - x1)
        b = y1 - m * x1
        Line.new(m,b)
      end
  end
  public
  # we put this in this class so all subclasses can inherit it:
  # the intersection of self with a NoPoints is a NoPoints object
  def intersectNoPoints np
    np # could also have NoPoints.new here instead
  end
  # we put this in this class so all subclasses can inhert it:
  # the intersection of self with a LineSegment is computed by
  # first intersecting with the line containing the segment and then
  # calling the result's intersectWithSegmentAsLineResult with the segment
  def intersectLineSegment seg
    line_result = intersect(two_points_to_line(seg.x1,seg.y1,seg.x2,seg.y2))
    line_result.intersectWithSegmentAsLineResult seg
  end
  # ADDED FOR SIMPLIFIED SUBCLASSES, SOME MAY OVERRIDE
  def eval_prog env 
    self # all values evaluate to self
  end
  def preprocess_prog
    self # no pre-processing to do here
  end
end


class NoPoints < GeometryValue
  # do *not* change this class definition: everything is done for you
  # (although this is the easiest class, it shows what methods every subclass
  # of geometry values needs)
  # Note: no initialize method only because there is nothing it needs to do
  def eval_prog env 
    self # all values evaluate to self
  end
  def preprocess_prog
    self # no pre-processing to do here
  end
  def shift(dx,dy)
    self # shifting no-points is no-points
  end
  def intersect other
    other.intersectNoPoints self # will be NoPoints but follow double-dispatch
  end
  def intersectPoint p
    self # intersection with point and no-points is no-points
  end
  def intersectLine line
    self # intersection with line and no-points is no-points
  end
  def intersectVerticalLine vline
    self # intersection with line and no-points is no-points
  end
  # if self is the intersection of (1) some shape s and (2) 
  # the line containing seg, then we return the intersection of the 
  # shape s and the seg.  seg is an instance of LineSegment
  def intersectWithSegmentAsLineResult seg
    self
  end
end


class Point < GeometryValue
  # *add* methods to this class -- do *not* change given code and do not
  # override any methods
  # Note: You may want a private helper method like the local
  # helper function inbetween in the ML code
  attr_reader :x, :y
  def initialize(x,y)
    @x = x
    @y = y
  end
  def shift(dx, dy)
    Point.new(@x + dx, @y + dy)
  end
  def intersect other
    other.intersectPoint self
  end
  def intersectPoint p
    if real_close_point(@x, @y, p.x, p.y)
      self
    else
      NoPoints.new
    end
  end
  def intersectLine line
    if real_close(@y, line.m * @x + line.b)
      self
    else
      NoPoints.new
    end
  end
  def intersectVerticalLine vline
    if real_close(@x, vline.x)
      self
    else
      NoPoints.new
    end
  end
  def intersectWithSegmentAsLineResult seg # check if point is within segment
    err = GeometryExpression::Epsilon
    check_x =
      (seg.x1 - err <= @x and @x <= seg.x2 + err) or
      (seg.x2 - err <= @x and @x <= seg.x1 + err)
    check_y =
      (seg.y1 - err <= @y and @y <= seg.y2 + err) or
      (seg.y2 - err <= @y and @y <= seg.y1 + err)
    if check_x and check_y
      self
    else
      NoPoints.new
    end
  end
end


class Line < GeometryValue
  # *add* methods to this class -- do *not* change given code and do not
  # override any methods
  attr_reader :m, :b 
  def initialize(m,b)
    @m = m
    @b = b
  end
  def shift(dx, dy)
    Line.new(@m, @b+dy-@m*dx)
  end
  def intersect other
    other.intersectLine self
  end
  def intersectPoint p
    p.intersectLine self
  end
  def intersectLine line
    if real_close(@m, line.m)
      if real_close(@b, line.b) # equiv lines
        self
      else # no intersection
        NoPoints.new()
      end
    else # intersect at a point
      x = (line.b - @b) / (@m - line.m)
      y = @m * x + @b
      Point.new(x, y)
    end
  end
  def intersectVerticalLine vline
    x = vline.x
    y = @m * x + @b
    Point.new(x, y)
  end
  def intersectWithSegmentAsLineResult seg
    seg
  end
end


class VerticalLine < GeometryValue
  # *add* methods to this class -- do *not* change given code and do not
  # override any methods
  attr_reader :x
  def initialize x
    @x = x
  end
  def shift(dx, _)
    VerticalLine.new(@x + dx)
  end
  def intersect other
    other.intersectVerticalLine self
  end
  def intersectPoint p
    p.intersectVerticalLine self
  end
  def intersectLine line
    line.intersectVerticalLine self
  end
  def intersectVerticalLine vline
    if real_close(@x, vline.x)
      self
    else
      NoPoints.new
    end
  end
  def intersectWithSegmentAsLineResult seg
    seg
  end
end


class LineSegment < GeometryValue
  # *add* methods to this class -- do *not* change given code and do not
  # override any methods
  # Note: This is the most difficult class.  In the sample solution,
  #  preprocess_prog is about 15 lines long and 
  # intersectWithSegmentAsLineResult is about 40 lines long
  attr_reader :x1, :y1, :x2, :y2
  def initialize (x1,y1,x2,y2)
    @x1 = x1
    @y1 = y1
    @x2 = x2
    @y2 = y2
  end
  def shift(dx, dy)
    new_x1 = @x1 + dx
    new_x2 = @x2 + dx
    new_y1 = @y1 + dy
    new_y2 = @y2 + dy
    if real_close_point(new_x1, new_y1, new_x2, new_y2)
      Point.new(new_x1, new_y1)
    else
      LineSegment.new(@x1 + dx, @y1 + dy, @x2 + dx, @y2 + dy)
    end
  end
  def preprocess_prog
    if real_close_point(@x1, @y1, @x2, @y2)
      Point.new(@x1, @y1)
    else
      if @x1 > @x2 and not real_close(@x1, @x2)
        LineSegment.new(@x2, @y2, @x1, @y1)
      else
        if real_close(@x1, @x2) and @y1 > @y2
          LineSegment.new(@x2, @y2, @x1, @y1)
        else
          self
        end
      end
    end
  end
  def intersect other
    other.intersectLineSegment self
  end
  def intersectPoint p
    p.intersectLineSegment self
  end
  def intersectLine line
    line.intersectLineSegment self
  end
  def intersectVerticalLine vline
    vline.intersectLineSegment self
  end
  def intersectWithSegmentAsLineResult seg
    # This method is copied directly from the SML part of the assignment
    x1start, y1start, x1end, y1end = @x1, @y1, @x2, @y2
    x2start, y2start, x2end, y2end = seg.x1, seg.y1, seg.x2, seg.y2
    seg1 = [x1start, y1start, x1end, y1end]
    seg2 = [x2start, y2start, x2end, y2end]
    # After creating all of the above variables, the below lines are almost word-for-word
    # taken from the SML implementation.
    if real_close(x1start, x1end)
      aXstart, aYstart, aXend, aYend, bXstart, bYstart, bXend, bYend = y1start < y2start ? seg1 + seg2 : seg2 + seg1
      if real_close(aYend, bYstart)
        Point.new(aXend, aYend)
      elsif aYend < bYstart
        NoPoints.new 
      elsif aYend > bYend
        LineSegment.new(bXstart, bYstart, bXend, bYend)
      else 
        LineSegment.new(bXstart, bYstart, aXend, aYend)
      end
    else
      aXstart, aYstart, aXend, aYend, bXstart, bYstart, bXend, bYend = x1start < x2start ? seg1 + seg2 : seg2 + seg1
      if real_close(aXend, bXstart)
        Point.new(aXend, aYend)
      elsif aXend < bXstart
        NoPoints.new
      elsif aXend > bXend
        LineSegment.new(bXstart, bYstart, bXend, bYend)
      else
        LineSegment.new(bXstart, bYstart, aXend, aYend)
      end
    end
  end
end


class Intersect < GeometryExpression
  # *add* methods to this class -- do *not* change given code and do not
  # override any methods
  def initialize(e1,e2)
    @e1 = e1
    @e2 = e2
  end
  def eval_prog env
    eval_e1 = @e1.eval_prog(env)
    eval_e2 = @e2.eval_prog(env)
    eval_e1.intersect(eval_e2)
  end
  def preprocess_prog
    prepro_e1 = @e1.preprocess_prog
    prepro_e2 = @e2.preprocess_prog
    Intersect.new(prepro_e1, prepro_e2)
  end
end


class Let < GeometryExpression
  # *add* methods to this class -- do *not* change given code and do not
  # override any methods
  # Note: Look at Var to guide how you implement Let
  def initialize(s,e1,e2)
    @s = s
    @e1 = e1
    @e2 = e2
  end
  def eval_prog env
    eval_first = @e1.eval_prog(env)
    new_env = [[@s, eval_first]]
    new_env += env
    @e2.eval_prog(new_env)
  end
  def preprocess_prog
    prepro_e1 = @e1.preprocess_prog
    prepro_e2 = @e2.preprocess_prog
    Let.new(@s, prepro_e1, prepro_e2)
  end
end


class Var < GeometryExpression
  # *add* methods to this class -- do *not* change given code and do not
  # override any methods
  def initialize s
    @s = s
  end
  def eval_prog env # remember: do not change this method
    pr = env.assoc @s
    raise "undefined variable" if pr.nil?
    pr[1]
  end
  def preprocess_prog
    self
  end
end


class Shift < GeometryExpression
  # *add* methods to this class -- do *not* change given code and do not
  # override any methods
  def initialize(dx,dy,e)
    @dx = dx
    @dy = dy
    @e = e
  end
  def preprocess_prog
    prepro = @e.preprocess_prog
    Shift.new(@dx, @dy, prepro)
  end
  def eval_prog env
    evaluated = @e.eval_prog(env)
    evaluated.shift(@dx, @dy)
  end
end
