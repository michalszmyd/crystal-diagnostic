module Files
  class FileDump
    property body : String
    property header : String
    property origin_path : String

    def initialize(@body, @header, @origin_path)
    end

    def dump(&)
      path = dump_path

      tempfile = File.tempfile("temp-file.cr", dir: path) do |file|
        file.puts(header)
        file.puts(sanitized_body)
      end

      yield tempfile.path

      tempfile.delete
    end

    def sanitized_body : String
      lucky_sanitize(body)
        .gsub(file_class_name, "#{file_class_name}Temp")
    end

    def file_class_name
      match = body.match(/class [^\n]*/)

      return "" unless match

      match.to_s.split("<")[0].rstrip
    end

    private def lucky_sanitize(value : String)
      [
        "put \"",
        "get \"",
        "post \"",
        "delete \"",
        "put(\"",
        "get(\"",
        "post(\"",
        "delete(\""
      ].each do |string|
        value = value.gsub(string, string + "/temp_capture")
      end

      value
    end

    private def dump_path
      fragments = origin_path.split("/")
      fragments[..-2].join("/")
    end
  end
end
