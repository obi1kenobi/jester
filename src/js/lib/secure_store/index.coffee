logger  = require('../util/logging').logger(['lib', 'sstore'])
storage = require('./storage')
crypto  = require('./crypto')

stringToData = (text) ->
  return JSON.parse(decryptedString).val

dataToString = (val) ->
  return JSON.stringify({val})


SecureStore =
  getProfileNames: () ->
    return storage.getProfileNames()

  get: (profile, storePassword, cb) ->
    profileData = storage.getProfile(profile)
    if !profileData?
      process.nextTick () -> cb("Profile #{profile} doesn't exist")
      return

    {salt, iv, authTag, ciphertext} = profileData
    crypto.decryptString ciphertext, storePassword, \
                         salt, iv, authTag, (err, decryptedString) ->
      if err?
        logger("Error decrypting data for profile #{profile}", err)
        cb?(err)
        return
      else
        secretData = stringToData(decryptedString)
        cb?(null, secretData)

  set: (profile, storePassword, secretData, cb) ->
    profileData = storage.getProfile(profile)
    if !profileData?
      process.nextTick () -> cb("Profile #{profile} doesn't exist")
      return

    {salt} = profileData
    dataString = dataToString(secretData)

    crypto.encryptString dataString, storePassword, salt, (err, res) ->
      if err?
        logger("Error encrypting data for profile #{profile}", err)
        cb?(err)
        return
      else
        {iv, authTag, ciphertext} = res
        storage.setProfile(profile, salt, iv, authTag, ciphertext)
        cb?()


module.exports = SecureStore
