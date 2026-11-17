require "./chunk"
require "./error_line"

module Parser
  class DiagnosticOutputParser
    property output : String

    def initialize(@output)
    end

    def build_chunks
      lines = output.split("\n")

      chunks = [] of Chunk
      chunk = Chunk.new
      push_to_chunk = false

      lines.each do |line|
        if line.match(/In /)
          push_to_chunk = true
          chunk.file_path = line.gsub("In ", "")
          chunk.message_type = Chunk::MessageType::Direct
        elsif line.match(/Which expanded to:/)
          push_to_chunk = true
          chunk.file_path = nil
          chunk.message_type = Chunk::MessageType::Macro
        end

        chunk.push_line line if push_to_chunk

        if line.match(/Error: |Warning: /)
          chunks.push(chunk)
          chunk = Chunk.new
          push_to_chunk = false
        end
      end

      chunks
    end

    def to_errors
      build_chunks.compact_map do |chunk|
        chunk_to_error(chunk)
      end
    end

    def chunk_to_error(chunk : Chunk)
      if chunk.type.error?
        ErrorLine.new(
          line: chunk.line_number,
          column: chunk.column_number,
          info: chunk.chunk_message,
        )
      end
    end
  end
end
