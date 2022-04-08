require "json"

require "./program"
require "./tokenizer"

module LxLang
  class Parser
    class Error < Exception
    end

    class SyntaxError < Error
    end

    @string : String
    @tokenizer : Tokenizer
    @lookahead : Token
    @queue = [] of Token

    def initialize(@string)
      @tokenizer = Tokenizer.new(@string)
      @lookahead = @tokenizer.next_token
    end

    def next_token_is?(token_type : Token.class)
      @lookahead.class <= token_type
    end

    def parse
      Program.new(parse_statement_list)
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
      case @lookahead
      when T::BlockStart
        statement = parse_block
      when T::If
        statement = parse_if_statement
      else
        statement = parse_expression
      end

      if terminator
        fetch_token(terminator)
      elsif next_token_is?(T::StatementEnd)
        fetch_token(T::StatementEnd)
      end

      statement
    end

    def parse_block : Block
      fetch_token(T::BlockStart)
      block = Block.new(parse_statement_list(T::BlockEnd))
    end

    def parse_if_statement
      value = fetch_token(T::If)
      condition = parse_statement(nil)
      consequent = parse_statement(nil)
      alternative = if next_token_is?(T::Else)
                      fetch_token(T::Else)
                      parse_statement
                    end
      IfStatement.new(value, condition, consequent, alternative)
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

      data_type : Token? = nil
      if next_token_is?(T::TypeAssign)
        fetch_token(T::TypeAssign)
        data_type = fetch_token(T::Type)
      end

      while next_token_is?(T::Assign)
        operator = fetch_token(T::Assign)
        right = if next_token_is?(T::BlockStart)
                  parse_block
                else
                  parse_assignment_expression
                end
        left = AssignmentExpression.new(operator, left, right, data_type)
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
      left = fetch_primary_expression

      while next_token_is?(T::Multiplicative)
        operator = fetch_token(T::Multiplicative)
        right = fetch_primary_expression
        left = BinaryExpression.new(operator, left, right)
      end

      left
    end

    def fetch_primary_expression
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
      raise SyntaxError.new("Unexpected end of input, expected #{token_types}") if token.nil?
      raise SyntaxError.new("Unexpected token #{token}, expected #{token_types}") unless token_types.any? { |t| token.class <= t }

      @lookahead = @tokenizer.next_token
      token
    end
  end
end
