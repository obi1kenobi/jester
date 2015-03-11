constants = require('../config/constants')

Proxies =
  ###
  Generate and return 'count' cryptographically-secure random bytes.
  ###
  getSecureRandomBytes: (count) ->
    throw new Error("Not overriden -- no implementation found")

nodeSetup = () ->
  crypto = require('crypto')
  Proxies.getSecureRandomBytes = (count) ->
    return crypto.randomBytes(count)

browserSetup = () ->
  passwordToBuffer = (password) ->
    buffer = new ArrayBuffer(password.length * 2)
    bufferView = new Uint16Array(buffer)
    for i in [0...password.length]
      bufferView[i] = password.charCodeAt(i)
    return buffer

  Proxies.getSecureRandomBytes = (count) ->
    window.crypto.getRandomValues(new Uint8Array(count))

  Proxies.getPBKDF2key = (password, cb) ->
    passwordBuffer = passwordToBuffer(password)
    promise = window.crypto.subtle.importKey "raw", \
                                             passwordBuffer, \
                                             constants.KEY_DERIVATION_ALGORITHM, \
                                             false, \
                                             constants.KEY_DERIVATION_PERMISSIONS
    promise.then (key) ->
      func = cb
      cb = null
      func?(null, key)

    promise.catch (err) ->
      func = cb
      cb = null
      func?(err)

  Proxies.generateEncryptionKey = (pbkdf2key, salt, cb) ->
    generatingAlgorithm =
      name: constants.KEY_DERIVATION_ALGORITHM
      salt: salt
      iterations: constants.KEY_DERIVATION_ITERATIONS
      hash: constants.KEY_DERIVATION_HASH

    promise = window.crypto.subtle.deriveKey generatingAlgorithm, \
                                             pbkdf2key, \
                                             constants.ENCRYPTION_ALGORITHM, \
                                             false, \
                                             constants.ENCRYPTION_PERMISSIONS

    promise.then (key) ->
      func = cb
      cb = null
      func?(null, key)

    promise.catch (err) ->
      func = cb
      cb = null
      func?(err)

if !window?
  # we're in Node
  nodeSetup()
else
  # running in browser
  browserSetup()

module.exports = Proxies
