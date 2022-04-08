require "string_scanner"
require "./token"
require "./tokens/*"

module LxLang
  class Tokenizer
    SPEC = {
      / +/                    => nil, # White Space
      /\n/                    => nil, # Newline
      /\#[^\n]*/              => nil, # Single line comment
      /;/                     => T::StatementEnd,
      /\{/                    => T::BlockStart,
      /\}/                    => T::BlockEnd,
      /\(/                    => T::ParenStart,
      /\)/                    => T::ParenEnd,
      /[><]=?/                => T::Comparison,
      /[=!]=/                 => T::Comparison,
      /&&/                    => T::And,
      /\|\|/                  => T::Or,
      /\=/                    => T::Assign,
      /\:/                    => T::TypeAssign,
      /\bif\b/                => T::If,
      /\belse\b/              => T::Else,
      /\btrue\b/              => T::Bool,
      /\bfalse\b/             => T::Bool,
      /\bnil\b/               => T::Nil,
      /\b[A-Z][A-Z\d_]*\b/    => T::Constant,
      /\b[a-z][a-zA-Z\d_]*\b/ => T::Identifier,
      /\b[A-Z][a-zA-Z\d_]*\b/ => T::Type,
      /[\*\/]/                => T::Multiplicative,
      /[\+\-]/                => T::Additive,
      /\d+_?i16/              => T::Int16,
      /\d+_?i32/              => T::Int32,
      /\d+(?:_?i8)?/          => T::Int8,
      /\"[^\"]*\"/            => T::String,
      /\'[^\']\'/             => T::Char,
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

    def next_token : Token
      until @scanner.eos?
        SPEC.each do |regex, token_class|
          result = @scanner.scan(regex)

          if result =~ /\n/
            @line_no += 1
            @last_line_char_no = @scanner.offset
          end

          next unless token_class && result
          token = token_class.new(result, line: @line_no, char: line_char - result.size)
          # puts "  TOKEN: #{regex.source.ljust(15)}: '#{result}' => #{token}"
          return token
        end
      end

      T::Eos.new("", line: @line_no, char: @scanner.offset - @last_line_char_no)
    end

    def eos?
      return true if @scanner.eos?
      @scanner.rest =~ /\s+\z/
    end
  end
end
