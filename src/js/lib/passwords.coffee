cryptoProxies = require('./crypto/proxies')
logger        = require('./util/logging').logger(['lib', 'passwd'])
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
  getPassword: (service, userPassword, cb) ->
    serviceData = storage.get createServiceStorageName(service)
    if !serviceData?
      logger("No stored data for service name: #{service}")
      process.nextTick () ->
        return cb?(new Error("No stored data for service name: #{service}"))
    else
      {ciphertext, salt, iv, authTag} = serviceData
      cryptoProxies.getOrCreateEncryptionKey userPassword, salt, (err, key) ->
        if err?
          return cb?(err)
        else
          cryptoProxies.decryptString ciphertext, key, iv, authTag, (err, result) ->
            if err?
              logger("Incorrect password or data corrupted!")
            return cb?(err, result)

  setRandomPassword: (service, userPassword, cb) ->
    salt = cryptoProxies.generateSalt()
    randomPassword = generateRandomPassword(constants.DEFAULT_PASSWORD_BYTES)

    cryptoProxies.getOrCreateEncryptionKey userPassword, salt, (err, key) ->
      if err?
        return cb?(err)
      else
        cryptoProxies.encryptString randomPassword, key, (err, result) ->
          if err?
            return cb?(err)
          else
            result.salt = salt
            storage.set(createServiceStorageName(service), result)
            return cb?(null, randomPassword)


module.exports = Passwords
