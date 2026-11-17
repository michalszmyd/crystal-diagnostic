module Files
  class Compiler
    property file_path : String

    def initialize(@file_path)
    end

    def compile
      output = IO::Memory.new
      error = IO::Memory.new

      channel = Channel(String?).new

      spawn do
        Process.run(
          "crystal",
          [
            "build",
            file_path,
            "--no-codegen",
          ],
          output: output,
          error: error
        )

        channel.send("#{error}#{output}")
      end

      value = channel.receive

      STDERR.puts(value)
      STDERR.puts("---")

      value || ""
    end
  end
end
