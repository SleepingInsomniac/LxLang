require "json"

module LxLang
  abstract class Token
    include JSON::Serializable

    getter type : String
    setter value : String
    property line : Int32
    property char : Int32

    def initialize(@value, @line, @char)
      @type = self.class.name
    end

    abstract def value

    def to_s(io)
      io << '<' << self.class.name << " " << @line << ":" << @char << " : " << value
    end
  end
end
