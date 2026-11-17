# TODO: Write documentation for `Crystal::Diagnostic`

require "./lsp/**"
require "./files/**"
require "./parser/**"

module Crystal::Diagnostic
  VERSION = "0.1.0"

  Lsp::Server.new.run
end
