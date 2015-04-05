constants   = require('../config/constants')
logger      = require('../util/logging').logger(['crypto', 'proxies'])
stringUtils = require('../util/string')

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
      callback(null, res)
    promise.catch (err) ->
      callback(err)

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
    promiseToCallback(promise, cb)

  generateEncryptionKey = (pbkdf2Key, salt, cb) ->
    generatingAlgorithm =
      name: constants.KEY_DERIVATION_ALGORITHM.name
      salt: stringToBuffer(salt)
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
      return
    else
      getPBKDF2key password, (err, derivedKey) ->
        if err?
          logger "Couldn't derive key from password."
          return cb?(err)
        else
          generateEncryptionKey derivedKey, salt, (err, key) ->
            if err?
              logger "Couldn't generate AES key."
              return cb?(err)
            else
              encryptionKeyCache[password][salt] = key
              return cb?(null, key)
  #
  # This variant is only to be used for testing in browsers that
  # do not support PBKDF2. THIS CODE IS NOT CONSIDERED SECURE!
  # Requires the helper methods defined at the bottom of this file.
  #
  # getSHA256key password, (err, hash) ->
  #   if err?
  #     logger "Couldn't hash the password: #{JSON.stringify(err)}"
  #     cb?(err)
  #   else
  #     createEncryptionKeyFromHash hash, (err, key) ->
  #       if err?
  #         logger "Couldn't generate AES key: #{JSON.stringify(err)}"
  #         cb?(err)
  #       else
  #         encryptionKeyCache[password][salt] = key
  #         cb?(null, key)

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
      iv         = stringUtils.arrayToBase64(iv)
      authTag    = stringUtils.arrayToBase64(authTag)
      cb?(null, {iv, authTag, ciphertext})

    promise.catch (err) ->
      cb?(err)

  Proxies.decryptString = (ciphertext, key, iv, authTag, cb) ->
    cipherBuffer = stringToBuffer(ciphertext)
    iv           = stringUtils.base64ToUint8Array(iv)
    authTag      = stringUtils.base64ToUint8Array(authTag)

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
    return bufferToString(Proxies.getSecureRandomBytes(length))

  Proxies.generateOneTimeCode = () ->
    digits = constants.ONE_TIME_CODE_DIGITS
    codeLimit = Math.pow(10, digits)
    bits = Math.log2(codeLimit)
    bytes = Math.ceil(bits / 8)

    if bits > 53
      throw new Error("Requested code of length #{digits}, " + \
                      "but it contains more bits than a Javascript Number")

    randomArray = window.crypto.getRandomValues(new Uint8Array(bytes-1))
    code = 0
    multiplier = 1
    for value in randomArray
      code += value * multiplier
      multiplier *= 256

    # make sure we don't get a larger code than we want, while preserving
    # a uniform randomness distribution

    lastByteArray = new Uint8Array(1)
    done = false
    while not done
      lastByte = window.crypto.getRandomValues(lastByteArray)[0]
      sum = code + (lastByte * multiplier)
      if sum < codeLimit
        code = sum
        done = true

    return code

  # Code only used for testing in browsers that do not support PBKDF2.
  # NOT CONSIDERED SECURE!
  #
  # getSHA256key = (password, cb) ->
  #   console.error "crypto:proxies: " + \
  #     "WARNING: Using SHA-256 to derive a key from a password, consider using PBKDF2 instead!"
  #   passwordBuffer = stringToBuffer(password)
  #   algorithm = {name: 'SHA-256'}
  #   promise = window.crypto.subtle.digest algorithm, passwordBuffer
  #   promiseToCallback(promise, cb)
  #
  # createEncryptionKeyFromHash = (hash, cb) ->
  #   promise = window.crypto.subtle.importKey 'raw', \
  #                                            hash, \
  #                                            constants.ENCRYPTION_ALGORITHM, \
  #                                            false, \
  #                                            constants.ENCRYPTION_PERMISSIONS
  #   promiseToCallback(promise, cb)

if !window?
  # we're in Node
  nodeSetup()
else
  # running in browser
  browserSetup()

module.exports = Proxies
