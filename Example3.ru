class C1
  def initialize; @x = nil; @y = nil; end
  def setx1(v) = @x = v
  def sety1(v) = @y = v
  def getx1    = @x
  def gety1    = @y
end

class C2 < C1
  # no new @y; it’s the same one defined in C1
  def sety2(v) = @y = v
  def getx2    = @x
  def gety2    = @y
end

o2 = C2.new
o2.setx1(101)
o2.sety1(102)
o2.sety2(999)
p [o2.getx1, o2.gety1, o2.getx2, o2.gety2]   # => [101, 999, 101, 999]
