Logging =
  ###
  Create a logger function. Takes an array of names, to be concatenated
  in the form a:b:c and prepended to any printed output.
  ###
  logger: (path) ->
    name = path.join(':') + ":"
    return () ->
      if arguments.length == 1
        console.log(name, arguments[0])
      else
        console.log(name, arguments)

nodeSetup = () ->
  module.exports = Logging

browserSetup = () ->
  define(Logging)

if module?.exports?
  # we're in Node
  nodeSetup()
else
  # running in browser
  browserSetup()
