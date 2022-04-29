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

  class BlockStart < SemanticToken
  end

  class BlockEnd < SemanticToken
  end

  class StatementEnd < SemanticToken
  end

  class Assign < SemanticToken
  end

  class TypeAssign < SemanticToken
  end

  class Comparison < SemanticToken
  end

  class Pipe < SemanticToken
  end

  class Navigator < SemanticToken
  end

  # ~~~~~~~~~~~~~~~~~~~~~~~~~~

  abstract class MathToken < SemanticToken
  end

  class Multiplicative < MathToken
  end

  class Additive < MathToken
  end

  # ~~~~~~~~~~~~~~~~~~~~~~~~~~

  abstract class Logical < SemanticToken
  end

  class And < Logical
  end

  class Or < Logical
  end

  class Not < Logical
  end
end
