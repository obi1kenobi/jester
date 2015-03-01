define ['lib/util/logging'], (logging) ->
  Core =
    _logger: logging.logger(["ext", "core"])

    start: () ->
      Core._logger("Hello world!")
