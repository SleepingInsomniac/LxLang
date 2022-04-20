require "./parser"
require "./code_gen"

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

# ast = LxLang::Parser.new(<<-PROG).parse
#   if true && x < 3 || 1 != 3
#     10
# PROG

# ast = LxLang::Parser.new(<<-PROG).parse
#   -x * -x
# PROG

# ast = LxLang::Parser.new(<<-PROG).parse
#   blah = { args ptr : @Int8, y : Int8, z : Int8
#
#     return parent;
#   }
# PROG

# ast = LxLang::Parser.new(<<-PROG).parse
#   in argv : Int8
#   out Int8
#
#   function = { in x : Int8, out Int8
#     if x % 3 == 0 {
#       return -1
#     } else if x % 5 == 0 {
#       return -2
#     }
#
#     return x
#   }
#
#   # TODO: function call
#
#   return 0
# PROG

ast = LxLang::Parser.new(<<-PROG).parse
  x = 4 + 2 + (3 - 2)
PROG

# puts ast.to_pretty_json

puts LxLang::CodeGen.new(ast).sap_asm
