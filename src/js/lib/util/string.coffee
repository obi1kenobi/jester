StringUtils =
  ###
  Converts the given byte array to a base64 encoded string.
  ###
  arrayToBase64: (arr) ->
    throw new Error("Not overriden -- no implementation found")

nodeSetup = () ->
  StringUtils.arrayToBase64 = (arr) ->
    buffer = new Buffer(arr)
    return buffer.toString('base64')

browserSetup = () ->
  StringUtils.arrayToBase64 = (arr) ->
    str = String.fromCharCode.apply(null, arr)
    return btoa(str)


if !window?
  # we're in Node
  nodeSetup()
else
  # running in browser
  browserSetup()

module.exports = StringUtils
