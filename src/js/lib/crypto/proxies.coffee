constants = require('../config/constants')
logger    = require('../util/logging').logger(['crypto', 'proxies'])

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
  encryptionKeyCache = {}

  stringToBuffer = (text) ->
    buffer = new ArrayBuffer(text.length * 2)
    bufferView = new Uint16Array(buffer)
    for i in [0...text.length]
      bufferView[i] = text.charCodeAt(i)
    return buffer

  bufferToString = (buffer) ->
    return String.fromCharCode.apply(null, new Uint16Array(buffer))

  getPBKDF2key = (password, cb) ->
    passwordBuffer = stringToBuffer(password)
    promise = window.crypto.subtle.importKey 'raw', \
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

  generateEncryptionKey = (pbkdf2key, salt, cb) ->
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

  Proxies.getOrCreateEncryptionKey = (password, salt, cb) ->
    if !encryptionKeyCache[password]?
      encryptionKeyCache[password] = {}

    key = encryptionKeyCache[password][salt]
    if key?
      process.nextTick () -> cb(null, key)
    else
      getPBKDF2key password, (err, pbkdf2key) ->
        if err?
          logger "Couldn't get pbkdf2 key."
          cb?(err)
        else
          generateEncryptionKey pbkdf2key, salt, (err, key) ->
            if err?
              logger "Couldn't generate AES key."
              cb?(err)
            else
              encryptionKeyCache[password][salt] = key
              cb?(null, key)

  ###
  Callback format is (error, result), where
  result = {iv, authTag, ciphertext}
  ###
  Proxies.encryptString = (plaintext, key, cb) ->
    textBuffer = stringToBuffer(plaintext)
    iv = Proxies.getSecureRandomBytes(16)
    authTag = Proxies.getSecureRandomBytes(constants.ENCRYPTION_AUTH_TAG_LENGTH)

    encryptionConfig =
      name: constants.ENCRYPTION_ALGORITHM.name
      iv: iv
      additionalData: authTag
      tagLength: constants.ENCRYPTION_AUTH_TAG_LENGTH

    promise = window.crypto.subtle.encrypt encryptionConfig, key, textBuffer

    promise.then (cipherBuffer) ->
      ciphertext = bufferToString(cipherBuffer)
      func = cb
      cb = null
      func?(null, {iv, authTag, ciphertext})

    promise.catch (err) ->
      func = cb
      cb = null
      func?(err)

  Proxies.decryptString = (ciphertext, key, iv, authTag, cb) ->
    cipherBuffer = stringToBuffer(ciphertext)

    decryptionConfig =
      name: constants.ENCRYPTION_ALGORITHM.name
      iv: iv
      additionalData: authTag
      tagLength: constants.ENCRYPTION_AUTH_TAG_LENGTH

    promise = window.crypto.subtle.decrypt decryptionConfig, key, cipherBuffer

    promise.then (textBuffer) ->
      plaintext = bufferToString(textBuffer)
      func = cb
      cb = null
      func?(null, plaintext)

    promise.catch (err) ->
      func = cb
      cb = null
      func?(err)

  Proxies.getSecureRandomBytes = (count) ->
    window.crypto.getRandomValues(new Uint8Array(count))

if !window?
  # we're in Node
  nodeSetup()
else
  # running in browser
  browserSetup()

module.exports = Proxies
