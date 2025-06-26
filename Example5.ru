# ----------------------------------------------------------
# c1  ⇢  C1
class C1
  def initialize          # (= method initialize () 1)
    # Ruby constructors return the object, not a number,
    # so we just leave it empty.
  end

  # method m1 () send self m2 ()
  def m1
    m2                    # dynamic dispatch, just like “send self m2 ()”
  end

  # method m2 () 13
  def m2
    13
  end
end

# ----------------------------------------------------------
# c2  ⇢  C2  (inherits C1)
class C2 < C1
  # method m1 () 22
  def m1
    22
  end

  # method m2 () 23
  def m2
    23
  end

  # method m3 () super m1 ()
  #
  # We need the *parent* version of m1 (C1#m1), not C2#m1.
  # Ruby lets us grab that UnboundMethod and invoke it:
  def m3
    C1.instance_method(:m1).bind(self).call
  end
end

# ----------------------------------------------------------
# c3  ⇢  C3  (inherits C2)
class C3 < C2
  # method m1 () 32
  def m1
    32
  end

  # method m2 () 33
  def m2
    33
  end
end

# ---------------- driver ----------------
o3 = C3.new            # let o3 = new c3()
puts o3.m3             # in send o3 m3()
# ⇒ 33
