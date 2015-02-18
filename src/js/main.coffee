requirejsConfig =
  baseUrl: '/js'

requirejs.config(requirejsConfig)

requirejs ['extension/core'], (ext) ->
  ext.start()
