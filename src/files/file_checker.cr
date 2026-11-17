require "yaml"

module Files
  class FileChecker
    WORK_ON_CLONED_FILE = true
    CLONED_SHARD_PATH = "tmp/project/shard.yml"

    @clone_path : String?

    property save_file_params : Lsp::SaveFileParams
    property project_attributes : Lsp::Meshes::ProjectAttributes

    def initialize(@save_file_params, @project_attributes)
      @clone_path = nil
    end

    def file_path
      save_file_params.text_document.path
    end

    def check
      return if file_path.includes?("tmp")

      Process.run(
        "cp",
        [file_path, clone_path]
      )

      header = "require \"#{entry_point_path}\""
      body = save_file_params.text

      errors = if CLONED_SHARD_PATH
        collector = nil

        FileDump.new(
          body: body,
          header: header,
          origin_path: clone_path
        ).dump do |path|
          output = Files::Compiler.new(file_path: path).compile
          collector = Parser::DiagnosticOutputParser.new(output).to_errors
        end

        collector
      else
        File.open(clone_path, "w") do |file|
          file.puts(header)
          file.puts(body)
        end

        output = Files::Compiler.new(file_path: clone_path).compile
        Parser::DiagnosticOutputParser.new(output).to_errors
      end

      errors
    end

    def clone_path : String
      @clone_path ||=
        file_path.sub(
          "#{project_attributes.project_name}",
          "#{project_attributes.project_name}/#{Files::ProjectLoader::PROJECT_CLONE_DESTINATION_PREFIX}"
        )
    end

    def entry_point_path
      relative = file_path.gsub(project_attributes.root_path + "/src", "").split("/")[1..].map { ".." }.join("/")

      [
        relative,
        entry_point
      ].join("/")
    end

    def entry_point
      yaml = File.open(CLONED_SHARD_PATH) do |file|
        YAML.parse(file)
      end

      targets = yaml["targets"]
      (targets.dig?(project_attributes.project_name) || targets[targets.as_h.keys.first]).dig?("main")
    end
  end
end
