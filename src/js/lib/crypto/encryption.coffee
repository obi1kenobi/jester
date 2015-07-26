logger      = require('../util/logging').logger(['lib', 'crypto', 'enc'])
stringUtils = require('../util/string')
constants   = require('../config/constants')
random      = require('./secure_random')

encryptionKeyCache = {}

promiseToCallback = (promise, callback) ->
  promise.then (res) ->
    callback(null, res)
  promise.catch (err) ->
    callback(err)

getPBKDF2 = (text, cb) ->
  buffer = stringUtils.stringToBuffer(text)
  promise = window.crypto.subtle.importKey 'raw', \
                                            buffer, \
                                            constants.KEY_DERIVATION_ALGORITHM, \
                                            false, \
                                            constants.KEY_DERIVATION_PERMISSIONS
  promiseToCallback(promise, cb)

getCryptoKey = (pbkdf2Key, salt, cb) ->
  generatingAlgorithm =
    name: constants.KEY_DERIVATION_ALGORITHM.name
    salt: stringUtils.stringToBuffer(salt)
    iterations: constants.KEY_DERIVATION_ITERATIONS
    hash: constants.KEY_DERIVATION_HASH

  promise = window.crypto.subtle.deriveKey generatingAlgorithm, \
                                           pbkdf2Key, \
                                           constants.ENCRYPTION_ALGORITHM, \
                                           false, \
                                           constants.ENCRYPTION_PERMISSIONS
  promiseToCallback(promise, cb)

getOrCreateEncryptionKey = (password, salt, cb) ->
  if !encryptionKeyCache[password]?
    encryptionKeyCache[password] = {}

  key = encryptionKeyCache[password][salt]
  if key?
    process.nextTick () -> cb?(null, key)
    return
  else
    getPBKDF2 password, (err, derivedKey) ->
      if err?
        logger "Couldn't derive key from password.", err
        return cb?(err)
      else
        getCryptoKey derivedKey, salt, (err, key) ->
          if err?
            logger "Couldn't generate AES key.", err
            return cb?(err)
          else
            encryptionKeyCache[password][salt] = key
            return cb?(null, key)


Crypto =
  ###
  Callback format is (error, result), where
  result = {iv, authTag, ciphertext}
  ###
  encryptString: (plaintext, password, salt, cb) ->
    getOrCreateEncryptionKey password, salt, (err, key) ->
      if err?
        cb?(err)
        return
      else
        textBuffer = stringUtils.stringToBuffer(plaintext)
        iv = random.getSecureRandomBytes(16)
        authTag = random.getSecureRandomBytes(constants.ENCRYPTION_AUTH_TAG_LENGTH)

        encryptionConfig =
          name: constants.ENCRYPTION_ALGORITHM.name
          iv: iv
          additionalData: authTag
          tagLength: constants.ENCRYPTION_AUTH_TAG_LENGTH

        promise = window.crypto.subtle.encrypt encryptionConfig, key, textBuffer

        promise.then (cipherBuffer) ->
          ciphertext = stringUtils.bufferToString(cipherBuffer)
          iv         = stringUtils.arrayToBase64(iv)
          authTag    = stringUtils.arrayToBase64(authTag)
          cb?(null, {iv, authTag, ciphertext})

        promise.catch (err) ->
          cb?(err)

  decryptString: (ciphertext, password, salt, iv, authTag, cb) ->
    getOrCreateEncryptionKey password, salt, (err, key) ->
      if err?
        cb?(err)
        return
      else
        cipherBuffer = stringUtils.stringToBuffer(ciphertext)
        iv           = stringUtils.base64ToUint8Array(iv)
        authTag      = stringUtils.base64ToUint8Array(authTag)

        decryptionConfig =
          name: constants.ENCRYPTION_ALGORITHM.name
          iv: iv
          additionalData: authTag
          tagLength: constants.ENCRYPTION_AUTH_TAG_LENGTH

        promise = window.crypto.subtle.decrypt decryptionConfig, key, cipherBuffer

        promise.then (textBuffer) ->
          plaintext = stringUtils.bufferToString(textBuffer)
          cb?(null, plaintext)

        promise.catch (err) ->
          cb?(err)


module.exports = Crypto
