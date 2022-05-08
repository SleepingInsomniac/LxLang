module LxLang
  class CodeGen
    @program : Program
    @declarations = {} of String => Int8
    @blocks = {} of String => Array(String)

    def initialize(@program)
    end

    def declare(name : String, value : Int8)
      @declarations[name] = value
    end

    def declare(assignment)
      return if @declarations[assignment.left.value]?

      init = if assignment.right.is_a?(T::Numeric)
               assignment.right.value
             else
               0
             end

      @declarations[assignment.left.value] = init
    end

    def sap_asm
      String.build do |io|
        instructions = [] of {String, String}
        sap_asm(instructions, @program.root_block, 0).each do |instr|
          io << "  " << instr[0].ljust(20) << "; " << instr[1] << "\n"
        end

        io << "  hlt\n\n"

        @declarations.each do |key, value|
          io << "  " << key << ": " << value << "\n"
        end
      end
    end

    def sap_asm(instructions, block, depth)
      block.body.each do |line|
        sap_exp(instructions, line, depth)
      end
      instructions
    end

    def sap_exp(instructions, exp, depth)
      case exp
      when Block
        sap_asm(instructions, exp, depth + 1)
      when BinaryExpression, AssignmentExpression
        sap_bin_exp(instructions, exp, depth + 1)
      when T::Numeric
        instructions << {"ldi #{exp.value}", exp.to_s}
      when IfStatment
        sap_conditional(condition, consequent, alternative)
      else
        instructions << {"", "Unhandled expression: #{exp.class.name}"}
      end
    end

    def sap_bin_exp(instructions, exp, depth)
      case exp.value
      when T::Additive
        declare("_tmp_#{depth}", 0)
        sap_exp(instructions, exp.left, depth + 1)
        instructions << {"sta :_tmp_#{depth}", ""}
        sap_exp(instructions, exp.right, depth + 1)
        if exp.value.value == "+"
          instructions << {"add :_tmp_#{depth}", ""}
        else
          declare("_tmp_#{depth}_1", 0)
          instructions << {"sta :_tmp_#{depth}_1", ""}
          instructions << {"lda :_tmp_#{depth}", ""}
          instructions << {"sub :_tmp_#{depth}_1", ""}
        end
      when T::Assign
        declare(exp.left.value.to_s, 0)
        sap_exp(instructions, exp.right, depth + 1)
        instructions << {"sta :#{exp.left.value}", ""}
      else
        instructions << {"", "Unhandled token: #{exp.value}"}
      end
    end

    def sap_conditional(condition, consequent, alternative)
    end
  end
end
