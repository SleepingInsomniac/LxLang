require "json"

module LxLang
  abstract class Token
    include JSON::Serializable

    getter type : String
    setter value : String
    property line : Int32
    property char : Int32

    def self.to_s(io)
      io << {{ @type.name.stringify.split("::").last }}
    end

    def initialize(@value, @line = 0, @char = 0)
      @type = self.class.name
    end

    abstract def value

    def to_s(io)
      io << self.class << " '" << @value << "' @ " << @line << ':' << @char
    end
  end
end
