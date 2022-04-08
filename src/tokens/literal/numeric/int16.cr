module LxLang::T
  class Int16 < Numeric
    def value
      @value[/\d+/].to_i16
    end
  end
end
