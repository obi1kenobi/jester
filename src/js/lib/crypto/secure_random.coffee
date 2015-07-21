logger      = require('../util/logging').logger(['lib', 'crypto', 'srand'])
stringUtils = require('../util/string')
constants   = require('../config/constants')

getSecureRandomBytes = (count) ->
  array = new Uint8Array(count)
  window.crypto.getRandomValues(array)
  return array


SecureRandom =
  getRandomPassword: (length) ->
    if length < constants.MIN_PASSWORD_BYTES
      throw new Error("Password length cannot be less than " + \
                      "#{constants.MIN_PASSWORD_BYTES} bytes, was #{length}.")
    bytes = getSecureRandomBytes(length)
    return stringUtils.arrayToBase64(bytes)

  getRandomSalt: () ->
    length = constants.SALT_BYTES
    return stringUtils.bufferToString(getSecureRandomBytes(length))

  getRandomNumericCode: (digits) ->
    codeLimit = Math.pow(10, digits)
    bits = Math.log2(codeLimit)
    bytes = Math.ceil(bits / 8)

    # 53 bits = 16 digits max
    if bits > 53
      throw new Error("Requested code of length #{digits}, " + \
                      "but it contains more bits than a Javascript Number")

    randomArray = getSecureRandomBytes(bytes - 1)
    code = 0
    multiplier = 1
    for value in randomArray
      code += (value * multiplier)
      multiplier *= 256

    # make sure we don't get a larger code than we want, while preserving
    # a uniform randomness distribution
    # --> keep drawing until we get a number under the limit

    done = false
    while not done
      lastByte = getSecureRandomBytes(1)[0]
      sum = code + (lastByte * multiplier)
      if sum < codeLimit
        code = sum
        done = true

    zeroPaddingcount = digits - ('' + code).length
    codeString = ''
    for i in [0...zeroPaddingcount]
      codeString += '0'
    codeString += code

    return codeString


module.exports = SecureRandom
