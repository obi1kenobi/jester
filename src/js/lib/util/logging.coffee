Logging =
  ###
  Create a logger function. Takes an array of names, to be concatenated
  in the form a:b:c and prepended to any printed output.
  ###
  logger: () ->
    name = arguments.join(':') + ":"
    return () ->
      arguments.unshift(name)
      console.log(arguments.join(' '))

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
