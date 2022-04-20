module LxLang::T
  abstract class IDToken < Token
    def value
      @value.gsub(/^@/, "")
    end

    def pointer?
      @value[0] == "@"
    end
  end

  class Identifier < IDToken
  end

  class Constant < IDToken
  end

  class Type < IDToken
  end
end
