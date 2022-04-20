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

  class While < Keyword
  end

  class Loop < Keyword
  end

  class Break < Keyword
  end

  class Return < Keyword
  end

  class In < Keyword
  end

  class Out < Keyword
  end

  class Public < Keyword
  end
end
