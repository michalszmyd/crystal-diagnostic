module Parser
  class Chunk
    enum ChunkType
      Warning
      Error
      Unknown
    end

    enum MessageType
      Macro
      Direct
    end

    property lines : Array(String)
    property file_path : String?
    property file_info : Hash(String, String)?
    property message_type : MessageType?

    def initialize()
      @lines = [] of String
    end

    def inspect
      {
        "type" => type,
        "file_info" => file_info,
        "chunk_message" => chunk_message
      }
    end

    def push_line(line : String)
      lines.push line
    end

    def file_info
      case message_type
      when MessageType::Direct
        direct_info
      when MessageType::Macro
        macro_info
      end
    end

    def macro_info
      error_line = lines.each_with_index.find do |element, index|
        [element, index] if element.match(/>\s+\d+\s+\|.*/)
      end

      return {
        "file_name" => "",
        "line_number" => 0,
        "column_number" => 0,
        "message" => "undefined"
      } unless error_line

      line_number, code = error_line[0].split(" | ")
      offset = line_number.size + code.split("").select { |e| e == " " }.size

      {
        "file_name" => "",
        "line_number" => line_number.gsub(">", "").to_i,
        "column_number" => offset,
        "message" => lines[-1]
      }
    end

    def direct_info
      file_info = file_path.try(&.split("/").last.split(":"))

      if file_info
        {
          "file_name" => file_info[0],
          "line_number" => file_info[1],
          "column_number" => file_info[2],
          "message" => lines[-1]
        }
      end
    end

    def line_number
      file_info.try { |info| info["line_number"].to_i } || 0
    end

    def column_number
      file_info.try { |info| info["column_number"].to_i } || 0
    end

    def chunk_message
      file_info.try { |info| info["message"] }.to_s || ""
    end

    def type
      return ChunkType::Unknown if lines.size == 0

      last_line = lines[-1]

      if last_line.match(/Error: /)
        ChunkType::Error
      elsif last_line.match(/Warning: /)
        ChunkType::Warning
      else
        ChunkType::Unknown
      end
    end
  end
end
