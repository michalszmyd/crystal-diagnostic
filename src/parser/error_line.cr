module Parser
  class ErrorLine
    enum ErrorLineType
      Internal
      External
    end

    property line : Int32
    property column : Int32
    property info : String

    def initialize(@line, @column, @info)
    end
  end
end
