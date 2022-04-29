require "json"

require "./program"
require "./tokenizer"

module LxLang
  class Error < Exception
  end

  class SyntaxError < Error
  end

  class Parser
    @string : String
    @tokenizer : Tokenizer
    @lookahead : Token
    @program : Program = Program.new
    @scope = [] of Block

    def initialize(@string)
      @tokenizer = Tokenizer.new(@string)
      @lookahead = @tokenizer.next_token
    end

    def next_token_is?(*token_types : Token.class)
      token_types.any? { |token_type| @lookahead.class <= token_type }
    end

    def parse
      begin
        @program = Program.new
        @program.root_block = parse_block(root: true)
        @program
      rescue e : SyntaxError
        puts "SyntaxError: #{e}"
        exit 1
      end
    end

    def parse_statement_list(terminator : Token.class = T::Eos)
      statements = [] of Statement | Block
      until next_token_is?(terminator)
        result = parse_statement
        case result
        when Array
          statements.concat result
        else
          statements << result
        end
      end
      fetch_token(terminator)
      statements
    end

    def parse_statement(terminator : Token.class | Nil = nil)
      statement =
        case @lookahead
        when T::BlockStart
          parse_block
        when T::If
          parse_if_statement
        when T::While
          parse_while_statement
        when T::Loop
          parse_loop_statement
        when T::Break
          Statement.new(fetch_token(T::Break))
        when T::Return
          parse_return_statement
        when T::Public
          parse_public_statement
        else
          parse_expression
        end

      if terminator
        fetch_token(terminator)
      elsif next_token_is?(T::StatementEnd)
        fetch_token(T::StatementEnd)
      end

      statement
    end

    def parse_return_statement
      operator = fetch_token(T::Return)

      expression =
        case @lookahead
        when T::BlockEnd
          nil
        else
          parse_expression
        end

      ReturnStatement.new(operator, expression)
    end

    def parse_public_statement
      fetch_token(T::Public)
      expression = parse_expression
      unless expression.is_a?(AssignmentExpression)
        raise Error.new("Invalid public variable declaration")
      end
      expression.is_public = true
      expression
    end

    def parse_block(root = false) : Block
      fetch_token(T::BlockStart) unless root

      params =
        if next_token_is?(T::In)
          parse_param_list
        end

      return_type =
        if next_token_is?(T::Out)
          fetch_token(T::Out)
          fetch_token(T::Type).as(T::Type)
        end

      block = Block.new(params, return_type)
      @scope.push block
      block.body = parse_statement_list(root ? T::Eos : T::BlockEnd)
      @scope.pop
      block
    end

    def parse_param_list
      fetch_token(T::In)
      params = [] of Param

      loop do
        identifer = fetch_token(T::Identifier)

        if next_token_is?(T::TypeAssign)
          fetch_token(T::TypeAssign)
          data_type = fetch_token(T::Type).as(T::Type)
        end

        if next_token_is?(T::Assign)
          fetch_token(T::Assign)
          default = fetch_token(T::Literal, T::Identifier, T::Constant)
        end

        params << Param.new(identifer, data_type, default)

        break unless next_token_is?(T::Separator)
        fetch_token(T::Separator)
        break if next_token_is?(T::Out)
      end

      params
    end

    def parse_if_statement
      value = fetch_token(T::If)
      condition = parse_statement(nil)
      consequent = parse_statement(nil)
      alternative =
        if next_token_is?(T::Else)
          fetch_token(T::Else)
          parse_statement
        end
      IfStatement.new(value, condition, consequent, alternative)
    end

    def parse_while_statement
      value = fetch_token(T::While)
      condition = parse_statement(nil)
      body = parse_statement(nil)
      WhileStatement.new(value, condition, body)
    end

    def parse_loop_statement
      value = fetch_token(T::Loop)
      body = parse_statement(nil)
      LoopStatement.new(value, body)
    end

    def parse_expression
      expression = parse_assignment_expression

      if expression.is_a?(Token)
        Expression.new(expression)
      else
        expression
      end
    end

    def parse_assignment_expression
      left = parse_logical_or_expression

      while next_token_is?(T::Assign, T::TypeAssign)
        if next_token_is?(T::TypeAssign)
          fetch_token(T::TypeAssign)
          data_type = fetch_token(T::Type).as(T::Type)
        end

        left =
          if next_token_is?(T::Assign)
            operator = fetch_token(T::Assign)

            right =
              if next_token_is?(T::BlockStart)
                parse_block
              else
                parse_assignment_expression
              end

            AssignmentExpression.new(operator, left, right, data_type)
          else
            AssignmentExpression.new(@tokenizer.fabricate(T::Assign), left, nil, data_type)
          end
      end

      left
    end

    def parse_logical_or_expression
      left = parse_logical_and_expression

      while next_token_is?(T::Or)
        operator = fetch_token(T::Or)
        right = parse_comparison_expression
        left = BinaryExpression.new(operator, left, right)
      end

      left
    end

    def parse_logical_and_expression
      left = parse_comparison_expression

      while next_token_is?(T::And)
        operator = fetch_token(T::And)
        right = parse_comparison_expression
        left = BinaryExpression.new(operator, left, right)
      end

      left
    end

    def parse_comparison_expression
      left = parse_additive_expression

      while next_token_is?(T::Comparison)
        operator = fetch_token(T::Comparison)
        right = parse_additive_expression
        left = BinaryExpression.new(operator, left, right)
      end

      left
    end

    def parse_additive_expression
      left = parse_multiplicative_expression

      while next_token_is?(T::Additive)
        operator = fetch_token(T::Additive)
        right = parse_multiplicative_expression
        left = BinaryExpression.new(operator, left, right)
      end

      left
    end

    def parse_multiplicative_expression
      left = parse_unary_expression

      while next_token_is?(T::Multiplicative)
        operator = fetch_token(T::Multiplicative)
        right = parse_unary_expression
        left = BinaryExpression.new(operator, left, right)
      end

      left
    end

    def parse_unary_expression
      case @lookahead
      when T::Additive, T::Not
        operator = fetch_token(T::Additive, T::Not)
        argument = parse_unary_expression
        UnaryExpression.new(operator, argument)
      else
        parse_call_expression
      end
    end

    def parse_call_expression
      exp = parse_member_expression

      while next_token_is?(T::ParenStart)
        value = fetch_token(T::ParenStart)
        arguments = parse_argument_list
        fetch_token(T::ParenEnd)
        exp = CallExpression.new(value, exp, arguments)
      end

      exp
    end

    def parse_argument_list
      arguments = [] of Statement | Token
      return arguments if next_token_is?(T::ParenEnd)

      loop do
        arguments.push(parse_assignment_expression)
        break unless next_token_is?(T::Separator)
        fetch_token(T::Separator)
      end

      arguments
    end

    def parse_member_expression
      left = parse_primary_expression

      while next_token_is?(T::Navigator)
        value = fetch_token(T::Navigator)
        left = MemberExpression.new(value, left, fetch_token(T::Identifier))
      end

      left
    end

    def parse_primary_expression
      case @lookahead
      when T::ParenStart
        fetch_token(T::ParenStart)
        expression = parse_expression
        fetch_token(T::ParenEnd)
        expression
      else
        fetch_token(T::Literal, T::IDToken, T::Constant, T::Assign)
      end
    end

    # Returns the current lookahead if it matches the provided *token_type* and sets the next token
    # from the tokenizer.
    def fetch_token(*token_types : Token.class) : Token
      token = @lookahead
      raise SyntaxError.new("Unexpected token #{token}, expected #{token_types}") unless token_types.any? { |t| token.class <= t }

      @lookahead = @tokenizer.next_token
      token
    end
  end
end
