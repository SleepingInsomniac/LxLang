module LxLang
  class Statement
    include JSON::Serializable

    getter type : String
    property value : Token | Statement

    def initialize(@value)
      @type = self.class.name
    end

    def to_s(io)
      io << self.class.name << ":\n" << @value
    end
  end

  class Expression < Statement
  end

  class BinaryExpression < Expression
    property left : Token | Statement
    property right : Token | Statement

    def initialize(@value, @left, @right)
      super(@value)
    end

    def to_s(io)
      io << self.class.name << " : " << @value.value << "\n  Left: " << @left << "\n  Right: " << @right
    end
  end

  class AssignmentExpression < Expression
    property data_type : Token?
    property left : Token | Statement
    property right : Token | Statement | Block

    def initialize(@value, @left, @right, @data_type = nil)
      raise "Invalid lefthand assignment #{@left}" unless @left.is_a?(T::Identifier | T::Constant)
      super(@value)
    end
  end

  class IfStatement < Statement
    property condition : Statement | Block
    property consequent : Statement | Block
    property alternative : Statement | Block | Nil

    def initialize(@value, @condition, @consequent, @alternative = nil)
      super(@value)
    end
  end
end
