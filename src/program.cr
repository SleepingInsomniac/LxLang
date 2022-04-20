require "./token"
require "./statement"
require "./block"

module LxLang
  class Program
    include JSON::Serializable

    getter type : String
    property root_block : Block = Block.new

    delegate :body, :body=, to: @root_block

    def initialize
      @type = self.class.name
    end

    def to_s(io)
      io << "Program:\n" << @body.join("\n")
    end
  end
end
