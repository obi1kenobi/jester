async         = require('../../../deps/async')
logger        = require('../../lib/util/logging').logger(['ext', 'profiles', 'state'])
secureStore   = require('../../lib/secure_store')
states        = require('./states')


updateProfile = (profile, storePassword, updateSecretData, cb) ->
  async.waterfall [
    (done) ->
      secureStore.getSecret(profile, storePassword, done)
    (secretData, done) ->
      publicData = secureStore.getPublic(profile)
      secretData = updateSecretData(secretData)

      secureStore.setProfile(profile, storePassword, publicData, secretData, done)
  ], cb


StateManager =
  isUsingRandomPassword: (profile, storePassword, cb) ->
    update = (secretData) ->
      {passwordData} = secretData
      passwordData.state = states.STEADY_STATE

      secretData.passwordData = passwordData
      return secretData
    updateProfile(profile, storePassword, update, cb)

  isCreatingToken: (profile, storePassword, token, cb) ->
    update = (secretData) ->
      {passwordData} = secretData
      passwordData.state = states.CREATING_TOKEN
      passwordData.token = token

      secretData.passwordData = passwordData
      return secretData
    updateProfile(profile, storePassword, update, cb)

  isUsingToken: (profile, storePassword, cb) ->
    update = (secretData) ->
      {passwordData} = secretData
      passwordData.state = states.USING_TOKEN

      secretData.passwordData = passwordData
      return secretData
    updateProfile(profile, storePassword, update, cb)

  isRevokingToken: (profile, storePassword, newRandomPassword, cb) ->
    update = (secretData) ->
      {passwordData} = secretData
      passwordData.state = states.REVOKING_TOKEN
      passwordData.randomPassword = newRandomPassword

      secretData.passwordData = passwordData
      return secretData
    updateProfile(profile, storePassword, update, cb)

  isInvalid: (profile, storePassword, cb) ->
    update = (secretData) ->
      {passwordData} = secretData
      passwordData.state = states.INVALID

      secretData.passwordData = passwordData
      return secretData
    updateProfile(profile, storePassword, update, cb)

  isInitializing: (profile, storePassword, service, publicData, username, \
                   userPassword, randomPassword, cb) ->
    passwordData = {userPassword, randomPassword, state: states.INITIALIZING}
    profileData = {service, username, passwordData}

    secureStore.setProfile(profile, storePassword, publicData, profileData, cb)

  isFinishedRepair: (profile, storePassword, service, publicData, username, \
                     userPassword, randomPassword, cb) ->
    passwordData = {userPassword, randomPassword, state: states.STEADY_STATE}
    profileData = {service, username, passwordData}

    secureStore.setProfile(profile, storePassword, publicData, profileData, cb)


module.exports = StateManager
