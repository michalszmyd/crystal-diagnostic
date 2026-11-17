module Lsp
  module Meshes
    class ProjectAttributes
      property process_id : Int32
      property root_path : String
      property root_uri : String
      property project_name : String

      def initialize(@process_id, @root_path, @root_uri)
        @project_name = @root_path.split("/").last
      end

      def self.from_json(json : JSON::Any)
        new(
          process_id: json["processId"].as_i,
          root_path: json["rootPath"].as_s,
          root_uri: json["rootUri"].as_s
        )
      end
    end
  end
end
