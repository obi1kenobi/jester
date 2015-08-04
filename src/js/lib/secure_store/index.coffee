logger  = require('../util/logging').logger(['lib', 'sstore'])
crypto  = require('../crypto/encryption')
random  = require('../crypto/secure_random')
storage = require('./storage')

stringToData = (text) ->
  return JSON.parse(text).val

dataToString = (val) ->
  return JSON.stringify({val})

encrypt = (storePassword, data, cb) ->
  salt = storage.getSalt()
  dataString = dataToString(data)
  crypto.encryptString dataString, storePassword, salt, cb

decrypt = (storePassword, data, cb) ->
  salt = storage.getSalt()
  {iv, authTag, ciphertext} = data
  crypto.decryptString ciphertext, storePassword, \
                       salt, iv, authTag, (err, decryptedString) ->
    if err?
      logger("Error decrypting data!", err)
      cb?(err)
      return
    else
      secretData = stringToData(decryptedString)
      cb?(null, secretData)


SecureStore =
  getProfileNames: () ->
    return storage.getProfileNames()

  getPublic: (profile) ->
    return storage.getProfile(profile)?.publicData

  getSecret: (profile, storePassword, cb) ->
    profileData = storage.getProfile(profile)
    if !profileData?
      process.nextTick () -> cb?("Profile #{profile} doesn't exist")
      return

    decrypt storePassword, profileData, cb

  setProfile: (profile, storePassword, publicData, secretData, cb) ->
    encrypt storePassword, secretData, (err, res) ->
      if err?
        logger("Error encrypting data for profile #{profile}", err)
        cb?(err)
        return
      else
        {iv, authTag, ciphertext} = res
        storage.setProfile(profile, iv, authTag, publicData, ciphertext)
        cb?()

  getConfig: (storePassword, cb) ->
    configData = storage.getConfig()
    if !configData?
      process.nextTick () -> cb?("No config data set.")
      return

    decrypt storePassword, configData, cb

  setConfig: (storePassword, config, cb) ->
    encrypt storePassword, config, (err, res) ->
      if err?
        logger("Error encrypting data for profile #{profile}", err)
        cb?(err)
        return
      else
        {iv, authTag, ciphertext} = res
        storage.setConfig(iv, authTag, ciphertext)
        cb?()

  configExists: () ->
    return storage.getConfig()?

module.exports = SecureStore
