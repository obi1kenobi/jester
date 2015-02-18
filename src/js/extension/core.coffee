Core = (logging) ->
  _logger: logging.logger(["ext", "core"])

  start: () ->
    Core._logger("Hello world!")

define(['lib/util/logging'], Core)
