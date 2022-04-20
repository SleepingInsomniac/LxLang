require "./token"
require "./statement"

module LxLang
  class Block
    include JSON::Serializable

    def self.to_s(io)
      io << {{ @type.name.stringify.split("::").last }}
    end

    getter type : String
    property params : Array(Param) | Nil = [] of Param
    property declarations : Array(Declaration) = [] of Declaration
    property return_type : T::Type | Nil = nil
    property body : Array(Statement | Block) = [] of Statement | Block

    def initialize
      @type = self.class.name
    end

    def initialize(@params, @return_type)
      @type = self.class.name
    end

    def to_s(io)
      io << self << "\n" << @body.join("\n")
    end
  end
end
