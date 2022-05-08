module LxLang
  class SAP
    struct Line
      @label : String?
      @op : String?
      @comment : String?

      def initialize(@label = nil, @op = nil, @comment = nil)
      end

      def to_s(io)
        io << @label << ": " if @label
        io << @op if @op
        io << "  ; " << @comment if @comment
      end
    end

    class Scope
      property vars = {} of String => Int32
      property parent : Scope? = nil
      property children : Array(Scope) = [] of Scope
      getter depth : Int32 = 0

      def initialize
      end

      def initialize(parent : Scope)
        @depth = parent.depth + 1
        parent.children << self
        @parent = parent
      end

      def declare(name : String, size : Int32)
        @vars[name] = size
      end

      def get(name : String)
        if result = @vars[name]?
          "#{@depth}_#{name}_#{result}"
        elsif parent
          parent.not_nil!.get(name)
        else
          raise "Variable #{name} does not exist within this scope (#{@depth})"
        end
      end
    end

    @program : Program
    @declarations = {} of String => Int8
    @blocks = {} of String => Array(Line)
    @anon_block_id : Int8 = 0
    @scope : Scope = Scope.new

    def initialize(@program)
    end

    def to_asm
      eval_block(@program.root_block, "_start")

      String.build do |io|
        @blocks.each do |label, lines|
          io << "\n" << label << ":\n"
          lines.each do |line|
            line.to_s(io)
            io << "\n"
          end
        end

        io << "\n  ; data\n"

        flatten_scope(@scope, io)
      end
    end

    def flatten_scope(scope, io)
      scope.vars.each do |var, bytes|
        io << scope.get(var) << ": "
        bytes.times do |n|
          io << "  0 ; byte " << n << "\n"
        end
      end

      scope.children.each do |child|
        flatten_scope(child, io)
      end
    end

    def eval_block(block, name : String? = nil)
      name ||= "anon_block_#{@anon_block_id += 1}"
      @scope = Scope.new(@scope)

      lines = [] of Line
      block.body.each do |statement|
        lines.concat(eval_statement(statement))
      end
      @blocks[name] = lines
      @scope.parent.try { |parent| @scope = parent }

      lines
    end

    def eval_statement(statement)
      case statement
      when AssignmentExpression
        eval_assignment(statement)
      when Expression
        [Line.new(op: "ldi #{statement.value}")]
      else
        [Line.new(comment: "Unhandled statement : #{statement.class.name}")]
      end
    end

    def eval_assignment(assignment)
      target = assignment.left
      raise "Cannot assign #{target}" unless target.is_a?(T::Identifier)
      size = if data_type = assignment.data_type
               case data_type
               when "Int8" then 1
               else
                 1
               end
             else
               1
             end

      @scope.declare(target.value, size)
      lines = eval_statement(assignment.right)
      lines << Line.new(op: "sta :#{@scope.get(target.value)}")
    end
  end
end
