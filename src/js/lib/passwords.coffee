Passwords = (cryptoProxies, logging, stringUtils, constants) ->
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

nodeSetup = () ->
  cryptoProxies = require('./crypto/proxies')
  logging = require('./util/logging')
  stringUtils = require('./util/string')
  constants = require('./config/constants')
  module.exports = Passwords(cryptoProxies, logging, stringUtils, constants)

browserSetup = () ->
  define(['crypto/proxies', \
          'util/logging',   \
          'util/string',    \
          'config/constants'], Passwords)

if module?.exports?
  # export for node.js
  nodeSetup()
else
  # export for browser
  browserSetup()
