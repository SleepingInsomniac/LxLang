module LxLang::T
  class Bool < Literal
    def value
      @value == "true" ? true : false
    end
  end
end
