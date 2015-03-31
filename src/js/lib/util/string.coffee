StringUtils =
  ###
  Converts the given byte array to a base64 encoded string.
  ###
  arrayToBase64: (arr) ->
    throw new Error("Not overriden -- no implementation found")

  base64ToUint8Array: (text) ->
    throw new Error("Not overriden -- no implementation found")

nodeSetup = () ->
  StringUtils.arrayToBase64 = (arr) ->
    buffer = new Buffer(arr)
    return buffer.toString('base64')

browserSetup = () ->
  StringUtils.arrayToBase64 = (arr) ->
    str = String.fromCharCode.apply(null, arr)
    return window.btoa(str)

  StringUtils.base64ToUint8Array = (text) ->
    conv = window.atob(text)
    array = new Uint8Array(conv.length)
    for i in [0...conv.length]
      array[i] = conv.charCodeAt(i)
    return array


if !window?
  # we're in Node
  nodeSetup()
else
  # running in browser
  browserSetup()

module.exports = StringUtils
