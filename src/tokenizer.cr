require "string_scanner"
require "./token"
require "./tokens/*"

module LxLang
  class Tokenizer
    class Error < Exception
    end

    class SyntaxError < Error
    end

    SPEC = {
      /;/                        => T::StatementEnd,
      /\{/                       => T::BlockStart,
      /\}/                       => T::BlockEnd,
      /\(/                       => T::ParenStart,
      /\)/                       => T::ParenEnd,
      /[><]=?/                   => T::Comparison,
      /[=!]=/                    => T::Comparison,
      /&&/                       => T::And,
      /\|\|/                     => T::Or,
      /\!/                       => T::Not,
      /\=/                       => T::Assign,
      /\:/                       => T::TypeAssign,
      /\|/                       => T::Pipe,
      /\,/                       => T::Separator,
      /\bin\b/                   => T::In,
      /\bout\b/                  => T::Out,
      /\bpub\b/                  => T::Public,
      /\bwhile\b/                => T::While,
      /\bloop\b/                 => T::Loop,
      /\bbreak\b/                => T::Break,
      /\breturn\b/               => T::Return,
      /\bif\b/                   => T::If,
      /\belse\b/                 => T::Else,
      /\btrue\b/                 => T::Bool,
      /\bfalse\b/                => T::Bool,
      /\bnil\b/                  => T::Nil,
      /\b[A-Z][A-Z\d_]*\b/       => T::Constant,
      /\b[a-z][a-zA-Z\d_]*\b/    => T::Identifier,
      /\@?\b[A-Z][a-zA-Z\d_]*\b/ => T::Type,
      /[\*\/\%]/                 => T::Multiplicative,
      /[\+\-]/                   => T::Additive,
      /\d+_?i16/                 => T::Int16,
      /\d+_?i32/                 => T::Int32,
      /\d+(?:_?i8)?/             => T::Int8,
      /\"[^\"]*\"/               => T::String,
      /\'[^\']\'/                => T::Char,
    }

    property string : String
    @scanner : StringScanner

    @line_no : Int32 = 1           # Track the current line number
    @last_line_char_no : Int32 = 0 # Char offset into the line

    def initialize(@string)
      @scanner = StringScanner.new(@string)
    end

    def line_char
      @scanner.offset - @last_line_char_no + 1
    end

    def advance_line
      @line_no += 1
      @last_line_char_no = @scanner.offset
    end

    def fabricate(token_type : Token.class)
      token_type.new("", line: @line_no, char: line_char)
    end

    def next_token : Token
      # Ignore white space
      loop do
        whitespace = @scanner.scan(/ +/)
        comment = @scanner.scan(/\#[^\n]*/)
        advance_line if newline = @scanner.scan(/\n/)
        break unless whitespace || comment || newline
      end

      SPEC.each do |regex, token_class|
        result = @scanner.scan(regex)

        next unless token_class && result
        token = token_class.new(result, line: @line_no, char: line_char - result.size)
        # puts "  TOKEN: #{regex.source.ljust(15)}: '#{result}' => #{token}"
        return token
      end

      unless @scanner.eos?
        raise SyntaxError.new("Unknown token: '#{@scanner.scan(/./)}' @ L#{@line_no}:#{line_char - 1}")
      end

      T::Eos.new("", line: @line_no, char: @scanner.offset - @last_line_char_no)
    end
  end
end
