cryptoProxies = require('./crypto/proxies')
logging       = require('./util/logging')
stringUtils   = require('./util/string')
constants     = require('./config/constants')
storage       = require('./storage')

###
Creates a new securely randomly-generated password, and returns it
encoded in base64.

@param length  {Number} the number of bytes the password should have
###
generateRandomPassword = (length) ->
  if length < constants.MIN_PASSWORD_BYTES
    throw new Error("Password length cannot be less than " + \
                    "#{constants.MIN_PASSWORD_BYTES} bytes, was #{length}.")
  bytes = cryptoProxies.getSecureRandomBytes(length)
  return stringUtils.arrayToBase64(bytes)

createServiceStorageName = (service) ->
  return "service-#{service}"

Passwords =
  getPassword: (service, user_password, cb) ->
    serviceData = storage.get createServiceStorageName(service)
    if !serviceData?
      process.nextTick () ->
        cb?(new Error("No stored data for service name: #{service}"))

    {ciphertext, salt, iv, authTag} = serviceData
    cryptoProxies.getOrCreateEncryptionKey user_password, salt, (err, key) ->
      if err?
        cb?(err)
      else
        cryptoProxies.decryptString ciphertext, key, iv, authTag, cb

  setRandomPassword: (service, user_password, cb) ->
    salt = cryptoProxies.generateSalt()
    randomPassword = generateRandomPassword(constants.DEFAULT_PASSWORD_BYTES)

    cryptoProxies.getOrCreateEncryptionKey user_password, salt, (err, key) ->
      if err?
        cb?(err)
      else
        cryptoProxies.encryptString randomPassword, key, (err, result) ->
          if err?
            cb?(err)
          else
            result.salt = salt
            storage.set(createServiceStorageName(service), result)
            cb?(null, randomPassword)


module.exports = Passwords
