module LxLang::T
  class Int8 < Numeric
    def value
      @value[/\d+/].to_i8
    end
  end
end
