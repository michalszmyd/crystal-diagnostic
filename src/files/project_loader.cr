module Files
  class ProjectLoader
    PROJECT_CLONE_DESTINATION_PREFIX = "tmp/project"
    SKIPPED_DIR_NAMES = ["spec", "LICENSE", "README.md", "tmp"]

    property project : Lsp::Meshes::ProjectAttributes

    def initialize(@project)
    end

    def load
      Process.run("mkdir", [PROJECT_CLONE_DESTINATION_PREFIX])

      list.each do |element|
        Process.run(
          "cp", ["-r", element, destination]
        )
      end
    end

    def destination
      project.root_path + "/" + PROJECT_CLONE_DESTINATION_PREFIX
    end

    def list
      dir = Dir.new(project.root_path)

      to_copy = dir.children.select do |source|
        next if source[0] == '.'
        next if SKIPPED_DIR_NAMES.includes?(source)

        source
      end

      to_copy.map do |source|
        project.root_path + "/" + source
      end
    end
  end
end
