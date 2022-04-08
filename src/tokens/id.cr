module LxLang::T
  abstract class IDToken < Token
    def value
      @value
    end
  end

  class Identifier < IDToken
  end

  class Constant < IDToken
  end

  class Type < IDToken
  end
end
