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

  promiseToCallback = (promise, callback) ->
    promise.then (res) ->
      callback?(null, res)
    promise.catch (err) ->
      callback?(err)

  stringToBuffer = (text) ->
    buffer = new ArrayBuffer(text.length * 2)
    bufferView = new Uint16Array(buffer)
    for i in [0...text.length]
      bufferView[i] = text.charCodeAt(i)
    return buffer

  bufferToString = (buffer) ->
    return String.fromCharCode.apply(null, new Uint16Array(buffer))

  # Temporary method, used until Chrome 42 is released (see TODO below)
  getSHA256key = (password, cb) ->
    console.error "crypto:proxies: " + \
      "WARNING: Using SHA-256 to derive a key from a password, consider using PBKDF2 instead!"
    passwordBuffer = stringToBuffer(password)
    algorithm = {name: 'SHA-256'}

    promise = window.crypto.subtle.digest algorithm, passwordBuffer

    promiseToCallback(promise, cb)

  # Temporary method, used until Chrome 42 is released (see TODO below)
  createEncryptionKeyFromHash = (hash, cb) ->
    promise = window.crypto.subtle.importKey 'raw', \
                                             hash, \
                                             constants.ENCRYPTION_ALGORITHM, \
                                             false, \
                                             constants.ENCRYPTION_PERMISSIONS
    promiseToCallback(promise, cb)

  getPBKDF2key = (password, cb) ->
    passwordBuffer = stringToBuffer(password)
    promise = window.crypto.subtle.importKey 'raw', \
                                             passwordBuffer, \
                                             constants.KEY_DERIVATION_ALGORITHM, \
                                             false, \
                                             constants.KEY_DERIVATION_PERMISSIONS
    promiseToCallback(promise, cb)

  generateEncryptionKey = (pbkdf2Key, salt, cb) ->
    generatingAlgorithm =
      name: constants.KEY_DERIVATION_ALGORITHM
      salt: salt
      iterations: constants.KEY_DERIVATION_ITERATIONS
      hash: constants.KEY_DERIVATION_HASH

    promise = window.crypto.subtle.deriveKey generatingAlgorithm, \
                                             pbkdf2Key, \
                                             constants.ENCRYPTION_ALGORITHM, \
                                             false, \
                                             constants.ENCRYPTION_PERMISSIONS
    promiseToCallback(promise, cb)

  Proxies.getOrCreateEncryptionKey = (password, salt, cb) ->
    if !encryptionKeyCache[password]?
      encryptionKeyCache[password] = {}

    key = encryptionKeyCache[password][salt]
    if key?
      process.nextTick () -> cb(null, key)
    else
      # TODO: When Chrome gets PBKDF2 support, use this block instead
      # getPBKDF2key password, (err, derivedKey) ->
      #   if err?
      #     logger "Couldn't derive key from password."
      #     cb?(err)
      #   else
      #     generateEncryptionKey derivedKey, salt, (err, key) ->
      #       if err?
      #         logger "Couldn't generate AES key."
      #         cb?(err)
      #       else
      #         encryptionKeyCache[password][salt] = key
      #         cb?(null, key)
      #
      # Until then, the following code will work but will be less secure:
      getSHA256key password, (err, hash) ->
        if err?
          logger "Couldn't hash the password: #{JSON.stringify(err)}"
          cb?(err)
        else
          createEncryptionKeyFromHash hash, (err, key) ->
            if err?
              logger "Couldn't generate AES key: #{JSON.stringify(err)}"
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
      cb?(null, {iv, authTag, ciphertext})

    promise.catch (err) ->
      cb?(err)

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
      cb?(null, plaintext)

    promise.catch (err) ->
      cb?(err)

  Proxies.getSecureRandomBytes = (count) ->
    window.crypto.getRandomValues(new Uint8Array(count))

  Proxies.generateSalt = () ->
    length = constants.SALT_BYTES
    return Proxies.getSecureRandomBytes(length)

if !window?
  # we're in Node
  nodeSetup()
else
  # running in browser
  browserSetup()

module.exports = Proxies
