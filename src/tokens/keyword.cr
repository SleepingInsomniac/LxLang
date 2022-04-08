module LxLang::T
  abstract class Keyword < Token
    def value
      @value
    end
  end

  class If < Keyword
  end

  class Else < Keyword
  end
end
