expect        = require('chai').expect
stringUtils   = require('../../src/js/lib/util/string')

describe 'String utils', () ->
  it 'array -> base64 -> array', () ->
    for cnt in [8..10]
      array = new Uint8Array(cnt)
      window.crypto.getRandomValues(array)

      base64 = stringUtils.arrayToBase64(array)
      array2 = stringUtils.base64ToUint8Array(base64)

      expect(array).to.eql(array2)

  it 'string -> buffer -> string', () ->
    text = "this is a test string"
    buffer = stringUtils.stringToBuffer(text)
    text2 = stringUtils.bufferToString(buffer)

    expect(text).to.eql(text2)
