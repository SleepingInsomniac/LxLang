module LxLang::T
  class String < Literal
    def value
      @value[1..-2]
    end
  end

  class Char < Literal
    def value
      @value[1..-2]
    end
  end
end
