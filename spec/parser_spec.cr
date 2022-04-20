require "./spec_helper"
require "../src/parser"

module LxLang
  describe Parser do
    it "parses i32 literals" do
      Parser.new("42;").parse.body.first.as(Statement).value.value.should eq(42)
    end

    it "parses string literals" do
      Parser.new("\"42\";").parse.body.first.as(Statement).value.value.should eq("42")
    end

    it "parses blocks" do
      Parser.new("{}").parse.body.first.should be_a(Block)
    end

    it "parses statements inside of a block" do
      Parser.new("{42;}").parse.body.first.as(Block).body.first.as(Statement).value.value.should eq(42)
    end

    it "parses addition" do
      statement = Parser.new("4 + 2;").parse.body.first.as(BinaryExpression)
      statement.value.value.should eq("+")
      statement.left.value.should eq(4)
      statement.right.value.should eq(2)
    end

    it "parses subtraction" do
      statement = Parser.new("4 - 2;").parse.body.first.as(BinaryExpression)
      statement.value.value.should eq("-")
      statement.left.value.should eq(4)
      statement.right.value.should eq(2)
    end

    it "parses chained addition and subtraction" do
      ast = Parser.new("6 - 4 + 2;").parse
      ast.to_pretty_json.should eq(<<-JSON)
      {
        "type": "LxLang::Program",
        "root_block": {
          "type": "LxLang::Block",
          "declarations": [],
          "body": [
            {
              "type": "LxLang::BinaryExpression",
              "value": {
                "type": "LxLang::T::Additive",
                "value": "+",
                "line": 1,
                "char": 7
              },
              "left": {
                "type": "LxLang::BinaryExpression",
                "value": {
                  "type": "LxLang::T::Additive",
                  "value": "-",
                  "line": 1,
                  "char": 3
                },
                "left": {
                  "type": "LxLang::T::Int8",
                  "value": "6",
                  "line": 1,
                  "char": 1
                },
                "right": {
                  "type": "LxLang::T::Int8",
                  "value": "4",
                  "line": 1,
                  "char": 5
                }
              },
              "right": {
                "type": "LxLang::T::Int8",
                "value": "2",
                "line": 1,
                "char": 9
              }
            }
          ]
        }
      }
      JSON
    end

    it "parses parens" do
      ast = Parser.new("6 - (4 + 2);").parse
      ast.to_pretty_json.should eq(<<-JSON)
      {
        "type": "LxLang::Program",
        "root_block": {
          "type": "LxLang::Block",
          "declarations": [],
          "body": [
            {
              "type": "LxLang::BinaryExpression",
              "value": {
                "type": "LxLang::T::Additive",
                "value": "-",
                "line": 1,
                "char": 3
              },
              "left": {
                "type": "LxLang::T::Int8",
                "value": "6",
                "line": 1,
                "char": 1
              },
              "right": {
                "type": "LxLang::BinaryExpression",
                "value": {
                  "type": "LxLang::T::Additive",
                  "value": "+",
                  "line": 1,
                  "char": 8
                },
                "left": {
                  "type": "LxLang::T::Int8",
                  "value": "4",
                  "line": 1,
                  "char": 6
                },
                "right": {
                  "type": "LxLang::T::Int8",
                  "value": "2",
                  "line": 1,
                  "char": 10
                }
              }
            }
          ]
        }
      }
      JSON
    end

    it "parses multiplication" do
      statement = Parser.new("4 * 2;").parse.body.first.as(BinaryExpression)
      statement.value.value.should eq("*")
      statement.left.value.should eq(4)
      statement.right.value.should eq(2)
    end

    it "parses multiplication precedence" do
      ast = Parser.new("6 + 4 * 2;").parse
      ast.to_pretty_json.should eq(<<-JSON)
      {
        "type": "LxLang::Program",
        "root_block": {
          "type": "LxLang::Block",
          "declarations": [],
          "body": [
            {
              "type": "LxLang::BinaryExpression",
              "value": {
                "type": "LxLang::T::Additive",
                "value": "+",
                "line": 1,
                "char": 3
              },
              "left": {
                "type": "LxLang::T::Int8",
                "value": "6",
                "line": 1,
                "char": 1
              },
              "right": {
                "type": "LxLang::BinaryExpression",
                "value": {
                  "type": "LxLang::T::Multiplicative",
                  "value": "*",
                  "line": 1,
                  "char": 7
                },
                "left": {
                  "type": "LxLang::T::Int8",
                  "value": "4",
                  "line": 1,
                  "char": 5
                },
                "right": {
                  "type": "LxLang::T::Int8",
                  "value": "2",
                  "line": 1,
                  "char": 9
                }
              }
            }
          ]
        }
      }
      JSON
    end

    it "parses assignment" do
      ast = Parser.new("a = 4 + 2;").parse
      ast.to_pretty_json.should eq(<<-JSON)
      {
        "type": "LxLang::Program",
        "root_block": {
          "type": "LxLang::Block",
          "declarations": [],
          "body": [
            {
              "type": "LxLang::AssignmentExpression",
              "value": {
                "type": "LxLang::T::Assign",
                "value": "=",
                "line": 1,
                "char": 3
              },
              "is_public": false,
              "left": {
                "type": "LxLang::T::Identifier",
                "value": "a",
                "line": 1,
                "char": 1
              },
              "right": {
                "type": "LxLang::BinaryExpression",
                "value": {
                  "type": "LxLang::T::Additive",
                  "value": "+",
                  "line": 1,
                  "char": 7
                },
                "left": {
                  "type": "LxLang::T::Int8",
                  "value": "4",
                  "line": 1,
                  "char": 5
                },
                "right": {
                  "type": "LxLang::T::Int8",
                  "value": "2",
                  "line": 1,
                  "char": 9
                }
              }
            }
          ]
        }
      }
      JSON
    end

    it "parse multiple assignments" do
      ast = Parser.new("y = x = 10;").parse
      ast.to_pretty_json.should eq(<<-JSON)
      {
        "type": "LxLang::Program",
        "root_block": {
          "type": "LxLang::Block",
          "declarations": [],
          "body": [
            {
              "type": "LxLang::AssignmentExpression",
              "value": {
                "type": "LxLang::T::Assign",
                "value": "=",
                "line": 1,
                "char": 3
              },
              "is_public": false,
              "left": {
                "type": "LxLang::T::Identifier",
                "value": "y",
                "line": 1,
                "char": 1
              },
              "right": {
                "type": "LxLang::AssignmentExpression",
                "value": {
                  "type": "LxLang::T::Assign",
                  "value": "=",
                  "line": 1,
                  "char": 7
                },
                "is_public": false,
                "left": {
                  "type": "LxLang::T::Identifier",
                  "value": "x",
                  "line": 1,
                  "char": 5
                },
                "right": {
                  "type": "LxLang::T::Int8",
                  "value": "10",
                  "line": 1,
                  "char": 9
                }
              }
            }
          ]
        }
      }
      JSON
    end

    it "parses if statements" do
      ast = Parser.new("if x y").parse
      ast.to_pretty_json.should eq(<<-JSON)
      {
        "type": "LxLang::Program",
        "root_block": {
          "type": "LxLang::Block",
          "declarations": [],
          "body": [
            {
              "type": "LxLang::IfStatement",
              "value": {
                "type": "LxLang::T::If",
                "value": "if",
                "line": 1,
                "char": 1
              },
              "condition": {
                "type": "LxLang::Expression",
                "value": {
                  "type": "LxLang::T::Identifier",
                  "value": "x",
                  "line": 1,
                  "char": 4
                }
              },
              "consequent": {
                "type": "LxLang::Expression",
                "value": {
                  "type": "LxLang::T::Identifier",
                  "value": "y",
                  "line": 1,
                  "char": 6
                }
              }
            }
          ]
        }
      }
      JSON
    end
  end
end
