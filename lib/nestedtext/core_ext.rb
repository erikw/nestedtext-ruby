class Array
  def to_nt(*_args)
    each.map do |e|
      e.to_s.prepend("- ")
    end.join("\n")
  end
end
