require "./spec_helper"
require "../src/tokenizer"

module LxLang
  describe Tokenizer do
    it "tokenizes a string" do
      tokenizer = Tokenizer.new(<<-STRING)
        ; {} ()
        # Comment
        < > <= >= == !=
        && || ! = :
        if else while loop break return
        CONST ident iDent_2 Type
        * / + -
        1 2i8 3i16 4i32
        "string" 'c' true false nil
      STRING

      [
        T::StatementEnd,   # ;
        T::BlockStart,     # {
        T::BlockEnd,       # }
        T::ParenStart,     # (
        T::ParenEnd,       # )
        T::Comparison,     # <
        T::Comparison,     # >
        T::Comparison,     # <=
        T::Comparison,     # >=
        T::Comparison,     # ==
        T::Comparison,     # !=
        T::And,            # &&
        T::Or,             # ||
        T::Not,            # !
        T::Assign,         # =
        T::TypeAssign,     # :
        T::If,             # if
        T::Else,           # else
        T::While,          # while
        T::Loop,           # loop
        T::Break,          # break
        T::Return,         # return
        T::Constant,       # CONST
        T::Identifier,     # ident
        T::Identifier,     # iDent_2
        T::Type,           # Type
        T::Multiplicative, # *
        T::Multiplicative, # /
        T::Additive,       # +
        T::Additive,       # -
        T::Int8,           # 1
        T::Int8,           # 2i8
        T::Int16,          # 3i16
        T::Int32,          # 4i32
        T::String,         # "string"
        T::Char,           # 'c'
        T::Bool,           # true
        T::Bool,           # false
        T::Nil,            # nil
        T::Eos,
      ].each do |token|
        tokenizer.next_token.class.should eq(token)
      end
    end
  end
end
