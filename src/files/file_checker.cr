require "yaml"

module Files
  class FileChecker
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

      STDERR.puts("file_path: #{file_path.inspect}")
      STDERR.puts("entry_point_path: #{entry_point_path.inspect}")
      STDERR.puts("clone_path: #{clone_path.inspect}")

      Process.run(
        "cp",
        [file_path, clone_path]
      )

      File.open(clone_path, "w") do |file|
        file.puts("require \"#{entry_point_path}\"")
        file.puts(save_file_params.text)
      end

      output = Files::Compiler.new(file_path: clone_path).compile
      errors = Parser::DiagnosticOutputParser.new(output).to_errors

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
      yaml = File.open("tmp/project/shard.yml") do |file|
        YAML.parse(file)
      end

      yaml["targets"][project_attributes.project_name]["main"].as_s?
    end
  end
end
