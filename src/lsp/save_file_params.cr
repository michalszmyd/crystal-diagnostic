module Lsp
  class SaveFileParams
    property text_document : Meshes::TextDocument
    property text : String

    def initialize(@text_document, @text)
    end

    def self.from_json(json : JSON::Any)
      text_document_json = json["textDocument"]
      text = json["text"].as_s

      text_document = Meshes::TextDocument.new(
        uri: text_document_json["uri"]?.try(&.as_s) || "",
        version: text_document_json["version"]?.try(&.as_i) || 0
      )

      new(
        text_document: text_document,
        text: text
      )
    end
  end
end
