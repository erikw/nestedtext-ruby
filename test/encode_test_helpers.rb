class Inner
  def initialize(val)
    @val = val
  end

  # TODO: need to create self.nt_create to encode this properly
  def to_nt(*args, **kwargs)
    @val.to_nt(*args, **kwargs)
  end

  def ==(other)
    other.class == self.class && other.state == state
  end
  alias eql? ==

  protected

  def state
    [@val]
  end
end

class Outer
  def initialize(a, b, c)
    @data = [a, b]
    @inner = Inner.new(c)
  end

  def to_nt(*args, **kwargs)
    # TODO: create helper method NestedText.EncodeClassKey(klass) to generate key name
    # See https://github.com/ruby/psych/blob/master/lib/psych/visitors/visitor.rb#L14
    ["class__Outer", @data + [@inner]].to_nt(*args, **kwargs)
  end

  def self.nt_create(object)
    new(*object[1])
  end

  def ==(other)
    other.class == self.class && other.state == state
  end
  alias eql? ==

  protected

  def state
    [@data, @inner]
  end
end

class Node
  attr_reader :data
  attr_accessor :nxt

  def self.from_enum(enum)
    head = nil
    node = nil
    enum.each do |e|
      nnode = Node.new(e)
      head = nnode if head.nil?
      node.nxt = nnode unless node.nil?
      node = nnode
    end
    head
  end

  def initialize(data, nxt = nil)
    @data = data
    @nxt = nxt
  end

  def ==(other)
    other.class == self.class && other.state == state
  end
  alias eql? ==

  def self.nt_create(object)
    data = object[1][0]
    nxt = object[1][1]
    new(data, nxt)
  end

  def to_nt(*args, **kwargs)
    ["class__Node", [@data, @nxt]].to_nt(*args, **kwargs)
  end

  protected

  def state
    [@data, @nxt]
  end
end
