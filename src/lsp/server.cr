require "json"

module Lsp
  class Server
    property? running : Bool
    property project_attributes : Lsp::Meshes::ProjectAttributes?

    def initialize
      @running = true
    end

    def run
      while running? && (header = STDIN.gets)
        next unless header.starts_with?("Content-Length")

        size = header["Content-Length: ".size..].to_i
        STDIN.gets

        raw = STDIN.read_string(size)
        message = JSON.parse(raw)

        on_event(message)
      end
    end

    def project : Lsp::Meshes::ProjectAttributes
      @project_attributes || raise "Project not specified"
    end

    private def on_event(message : JSON::Any)
      method = message["method"]?.try(&.as_s)
      id = message["id"]?.try(&.as_i?)
      params = message["params"]? || JSON.parse("{}")

      STDERR.puts(method)

      case method
        when "initialize"
          @project_attributes = Lsp::Meshes::ProjectAttributes.from_json(params)
          Files::ProjectLoader.new(project: project).load

          respond(id, {
            capabilities: {
              textDocumentSync: {
                openClose: true,
                change: 0,
                save: {
                  includeText: true
                }
              }
            }
          }.to_json
        )
        when "textDocument/didOpen"
#           data = Lsp::SaveFileParams.from_json(params)
#
#           STDERR.puts(data.inspect)
        when "textDocument/didSave"
          data = Lsp::SaveFileParams.from_json(params)
          checker = Files::FileChecker.new(
            save_file_params: data,
            project_attributes: project
          )

          errors = checker.check

          if errors
            diagnostics = errors.map do |error|
              Lsp::Diagnostic.new(
                line_start: error.line,
                line_end: error.line,
                row_start: error.column,
                row_end: error.column + 3,
                error: error.info
              ).to_lsp_diagnostic
            end

            payload = {
              uri: data.text_document.uri,
              diagnostics: diagnostics
            }.to_json

            STDERR.puts(payload.inspect)

            notify(
              "textDocument/publishDiagnostics",
              params: payload
            )
          end
        when "shutdown"
          @running = false
      end
    end

    private def respond(id : Int32?, result : String)
      json = { jsonrpc: "2.0", id: id, result: JSON.parse(result) }.to_json
      send_raw(json)
    end

    private def notify(method : String, params : String)
      json = { jsonrpc: "2.0", method: method, params: JSON.parse(params) }.to_json
      send_raw(json)
    end

    private def send_raw(json)
      STDOUT.print "Content-Length: #{json.bytesize}\r\n"
      STDOUT.print "\r\n"
      STDOUT.print json
      STDOUT.flush
    end
  end
end
