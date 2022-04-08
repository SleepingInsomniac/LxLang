module LxLang::T
  class Int32 < Numeric
    def value
      @value[/\d+/].to_i32
    end
  end
end
