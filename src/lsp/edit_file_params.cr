require "./meshes/**"

module Lsp
  class EditFileParams
    property text_document : Meshes::TextDocument
    property content_changes : Array(Meshes::ContentChange)

    def initialize(@text_document, @content_changes)
    end

    def self.from_json(json : JSON::Any)
      text_document_json = json["textDocument"]
      content_changes_json = json["contentChanges"].as_a

      text_document = TextDocument.new(
        uri: text_document_json["uri"]?.try(&.as_s) || "",
        version: text_document_json["version"]?.try(&.as_i) || 0
      )

      content_changes = content_changes_json.map do |content_json|
        ContentChange.new(
          text: content_json["text"].try(&.as_s) || ""
        )
      end

      new(
        text_document: text_document,
        content_changes: content_changes
      )
    end
  end
end
