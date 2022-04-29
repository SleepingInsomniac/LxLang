module LxLang
  class Statement
    class Error < Exception
    end

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

  class UnaryExpression < Expression
    property argument : Token | Statement | Nil

    def initialize(@value, @argument)
      super(@value)
    end
  end

  class BinaryExpression < Expression
    property left : Token | Statement
    property right : Token | Statement

    def initialize(@value, @left, @right)
      super(@value)
    end
  end

  class Param < Expression
    property data_type : T::Type | Nil
    property default : Token | Nil

    def initialize(@value, @data_type = nil, @default = nil)
      raise Error.new("Invalid default assignment #{@default}") unless @default.is_a?(Nil | T::Identifier | T::Constant | T::Literal)
      super(@value)
    end
  end

  class Declaration
    include JSON::Serializable

    getter type : String
    property name : T::Identifier | T::Constant
    property data_type : T::Type

    def initialize(@name, @data_type)
      @type = self.class.name
    end
  end

  class AssignmentExpression < Expression
    property data_type : Token?
    property is_public : Bool = false
    property left : Token | Statement
    property right : Token | Statement | Block | Nil

    def initialize(@value, @left, @right, @data_type = nil)
      raise Error.new("Invalid lefthand assignment #{@left}") unless @left.is_a?(T::Identifier | T::Constant | MemberExpression)
      super(@value)
    end
  end

  class MemberExpression < BinaryExpression
  end

  class CallExpression < Expression
    property caller : Token | Statement
    property arguments : Array(Token | Statement) = [] of Token | Statement

    def initialize(@value, @caller, arguments : Array(Token | Statement)?)
      super(@value)
      @arguments = arguments if arguments
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

  class WhileStatement < Statement
    property condition : Statement | Block
    property body : Statement | Block

    def initialize(@value, @condition, @body)
      super(@value)
    end
  end

  class LoopStatement < Statement
    property body : Statement | Block

    def initialize(@value, @body)
      super(@value)
    end
  end

  class ReturnStatement < Statement
    property expression : Expression | Nil

    def initialize(@value, @expression)
      super(@value)
    end
  end
end
