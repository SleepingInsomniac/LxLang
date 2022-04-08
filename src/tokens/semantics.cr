module LxLang::T
  abstract class SemanticToken < Token
    def value
      @value
    end
  end

  class Separator < SemanticToken
  end

  class ParenStart < SemanticToken
  end

  class ParenEnd < SemanticToken
  end

  class StatementEnd < SemanticToken
  end

  abstract class MathToken < SemanticToken
  end

  class Multiplicative < MathToken
  end

  class Additive < MathToken
  end

  class Assign < SemanticToken
  end

  class BlockStart < SemanticToken
  end

  class BlockEnd < SemanticToken
  end

  class TypeAssign < SemanticToken
  end

  class Comparison < SemanticToken
  end

  class Logical < SemanticToken
  end

  class Or < SemanticToken
  end

  class And < SemanticToken
  end
end
