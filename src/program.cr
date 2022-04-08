require "./token"
require "./statement"
require "./block"

module LxLang
  class Program
    include JSON::Serializable

    getter type : String
    property body : Array(Statement | Block) = [] of Statement | Block

    def initialize
      @type = self.class.name
    end

    def initialize(@body)
      @type = self.class.name
    end

    def to_s(io)
      io << "Program:\n" << @body.join("\n")
    end
  end
end