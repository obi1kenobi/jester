cryptoProxies = require('./crypto/proxies')
logging       = require('./util/logging')
stringUtils   = require('./util/string')
constants     = require('./config/constants')

Passwords =
  ###
  Creates a new securely randomly-generated password, and returns it
  encoded in base64.

  @param length  {Number} the number of bytes the password should have
  ###
  generateRandomPassword: (length) ->
    if length < constants.MIN_PASSWORD_BYTES
      throw new Error("Password length cannot be less than " + \
                      "#{constants.MIN_PASSWORD_BYTES} bytes, was #{length}.")
    bytes = cryptoProxies.getSecureRandomBytes(length)
    return stringUtils.arrayToBase64(bytes)

  decryptPassword: (encrypted) ->
    throw new Error("Not implemented")

  encryptPassword: (password) ->
    throw new Error("Not implemented")


module.exports = Passwords
