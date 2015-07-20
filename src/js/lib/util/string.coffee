StringUtils =
  ###
  Converts the given byte array to a base64 encoded string.
  ###
  arrayToBase64: (arr) ->
    str = String.fromCharCode.apply(null, arr)
    return window.btoa(str)

  ###
  Converts a base64 encoded string to a byte array
  ###
  base64ToUint8Array: (text) ->
    conv = window.atob(text)
    array = new Uint8Array(conv.length)
    for i in [0...conv.length]
      array[i] = conv.charCodeAt(i)
    return array

  stringToBuffer: (text) ->
    buffer = new ArrayBuffer(text.length * 2)
    bufferView = new Uint16Array(buffer)
    for i in [0...text.length]
      bufferView[i] = text.charCodeAt(i)
    return buffer

  bufferToString: (buffer) ->
    return String.fromCharCode.apply(null, new Uint16Array(buffer))


module.exports = StringUtils
