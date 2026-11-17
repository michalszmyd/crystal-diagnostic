module Lsp
  class Diagnostic
    SOURCE = "crystal-diagnostic"

    property line_start : Int32
    property line_end : Int32
    property row_start : Int32
    property row_end : Int32
    property error : String

    def initialize(@line_start, @line_end, @row_start, @row_end, @error)
    end

    def to_lsp_diagnostic
      {
        range: {
          start: { line: line_start - 2, character: row_start - 1 },
          end:   { line: line_end - 2, character: row_end - 1 }
        },
        severity: 1,
        source:   SOURCE,
        message:  error
      }
    end
  end
end
