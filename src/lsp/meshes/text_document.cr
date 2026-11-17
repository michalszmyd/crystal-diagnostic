module Lsp
  module Meshes
    class TextDocument
      property uri : String
      property path : String
      property version : Int32

      def initialize(@uri, @version)
        @path = uri.gsub("file://", "")
      end
    end
  end
end
