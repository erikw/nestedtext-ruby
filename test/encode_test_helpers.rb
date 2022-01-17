require "nestedtext/to_nt_mixin"

class Inner
  include NestedText::NTEncodeMixing
  def initialize(val)
    @val = val
  end

  def self.nt_create(object)
    new(*object[1])
  end

  def encode_nt_with
    ["class__Inner", [@val]]
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
  def initialize(a, b, inner)
    @data = [a, b]
    @inner = inner
  end

  def self.nt_create(object)
    new(*object[1])
  end

  def encode_nt_with
    # TODO: create helper method NestedText.EncodeClassKey(klass) to generate key name
    # See https://github.com/ruby/psych/blob/master/lib/psych/visitors/visitor.rb#L14
    # TODO document that if no deserialization is needed, it can be enough to do: alias to_nt to_s
    # TODO convert this to a dict when dict is implemented
    ["class__Outer", @data + [@inner]]
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

  def encode_nt_with
    ["class__Node", [@data, @nxt]]
  end

  protected

  def state
    [@data, @nxt]
  end
end
