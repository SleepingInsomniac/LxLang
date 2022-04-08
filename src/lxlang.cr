require "./parser"

module Lxlang
  VERSION = "0.1.0"
end

# ast = LxLang::Parser.new(<<-PROG).parse
#   42; # Comment
#   "42";
#   {
#     42_i8;
#     {
#       "Hello";
#       x : Int32 = 4 * 3 + (5 - 2);
#     }
#   }
# PROG

# ast = LxLang::Parser.new(<<-PROG).parse
#   42 + 3 + 10;
# PROG

# ast = LxLang::Parser.new(<<-PROG).parse
#   (2 + 2) * 2;
# PROG

# ast = LxLang::Parser.new(<<-PROG).parse
#   y = (42 + 10);
# PROG

# ast = LxLang::Parser.new(<<-PROG).parse
#   foo = {
#     42;
#   };
# PROG

# ast = LxLang::Parser.new(<<-PROG).parse
#   if true
#     x = 2
#   else if false
#     x = 3
#   else {
#     4
#     5
#     6
#   }
# PROG

ast = LxLang::Parser.new(<<-PROG).parse
  if true && x < 3 || 1 >= 3
    10
PROG

puts ast.to_pretty_json
