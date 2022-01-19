require "nestedtext/encode_helpers"

class Inner
  include NestedText::NTEncodeMixing
  def initialize(val)
    @val = val
  end

  def self.nt_create(data)
    new(data)
  end

  def encode_nt_with
    NestedText::EncodeWithData self, @val
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
    @list = [a, b]
    @inner = inner
  end

  def self.nt_create(data)
    new(*data)
  end

  def encode_nt_with
    NestedText::EncodeWithData self, [*@list, @inner]
  end

  def ==(other)
    other.class == self.class && other.state == state
  end
  alias eql? ==

  protected

  def state
    [@list, @inner]
  end
end

class Node
  attr_reader :value
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

  def initialize(value, nxt = nil)
    @value = value
    @nxt = nxt
  end

  def ==(other)
    other.class == self.class && other.state == state
  end
  alias eql? ==

  def self.nt_create(data)
    value = data[0]
    nxt = data[1]
    new(value, nxt)
  end

  def encode_nt_with
    NestedText::EncodeWithData self, [@value, @nxt]
  end

  protected

  def state
    [@value, @nxt]
  end
end

class NotNTEncodable; end
