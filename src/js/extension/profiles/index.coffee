logger        = require('../../lib/util/logging').logger(['ext', 'profiles'])
secureStore   = require('../../lib/secure_store')
secureRandom  = require('../../lib/crypto/secure_random')
constants     = require('../../lib/config/constants')
services      = require('../services')

states =

  # ### State flow: ###
  #
  # - new user account created:     INITIALIZING
  #                                      \/
  # - changed password to random:   STEADY_STATE  <---+
  #                                      \/           |
  # - requested token:             CREATING_TOKEN     |
  #                                      \/           | (token successfully revoked)
  # - token created successfully:    USING_TOKEN      |
  #                                      \/           |
  # - token about to be revoked:   REVOKING_TOKEN ----+
  #

  # current password: user password
  # changing to:      random password
  INITIALIZING: 'initializing'

  # current password: random password
  # changing to:      none
  STEADY_STATE: 'steady-state'

  # current password: random password
  # changing to:      user password + token
  CREATING_TOKEN: 'creating-token'

  # current password: user password + token
  # changing to:      none
  USING_TOKEN: 'using-token'

  # current password: user password + token
  # changing to:      random password
  REVOKING_TOKEN: 'revoking-token'


updateProfile = (profile, storePassword, updateSecretData, cb) ->
  async.waterfall [
    (done) ->
      secureStore.getSecret(profile, storePassword, done)
    (secretData, done) ->
      publicData = secureStore.getPublic(profile)
      secretData = updateSecretData(secretData)

      secureStore.setProfile(profile, storePassword, publicData, secretData, done)
  ], cb

isUsingRandomPassword = (profile, storePassword, cb) ->
  update = (secretData) ->
    {passwordData} = secretData
    passwordData.state = states.STEADY_STATE

    secretData.passwordData = passwordData
    return secretData
  updateProfile(profile, storePassword, update, cb)

isCreatingToken = (profile, storePassword, token, cb) ->
  update = (secretData) ->
    {passwordData} = secretData
    passwordData.state = states.CREATING_TOKEN
    passwordData.token = token

    secretData.passwordData = passwordData
    return secretData
  updateProfile(profile, storePassword, update, cb)

isUsingToken = (profile, storePassword, cb) ->
  update = (secretData) ->
    {passwordData} = secretData
    passwordData.state = states.USING_TOKEN

    secretData.passwordData = passwordData
    return secretData
  updateProfile(profile, storePassword, update, cb)

isRevokingToken = (profile, storePassword, newRandomPassword, cb) ->
  update = (secretData) ->
    {passwordData} = secretData
    passwordData.state = states.REVOKING_TOKEN
    passwordData.randomPassword = newRandomPassword

    secretData.passwordData = passwordData
    return secretData
  updateProfile(profile, storePassword, update, cb)

ProfileManager =
  getAll: (storePassword, cb) ->
    response = {}
    profiles = secureStore.getProfileNames()

    async.map profiles, (profile, done) ->
      secureStore.getSecret(profile, storePassword, done)
    , (err, result) ->
      if err?
        return cb(err)
      else
        for i in [0...profiles.length]
          # TODO(predrag): Remove this call before publishing; only for testing purposes
          # console.error "ext:profiles: Profile #{i}: #{JSON.stringify(result[i])}"

          {service, username} = result[i]
          response[profiles[i]] = {service, username}

        cb(null, response)

  createNew: (profile, storePassword, service, username, userPassword, cb) ->
    randomPassword = secureRandom.getRandomPassword(constants.DEFAULT_PASSWORD_BYTES)
    passwordData = {userPassword, randomPassword, state: states.INITIALIZING}
    profileData = {service, username, passwordData}

    async.series [
      (done) ->
        secureStore.setProfile(profile, storePassword, {}, profileData, done)
      (done) ->
        services.setup(service, username, userPassword, randomPassword, done)
      (done) ->
        isUsingRandomPassword(profile, storePassword, done)
    ], cb

  getToken: (profile, storePassword, tokenSetCb, tokenResetCb) ->
    token = secureRandom.getRandomNumericCode(constants.ONE_TIME_CODE_DIGITS)
    nextPassword = secureRandom.getRandomPassword(constants.DEFAULT_PASSWORD_BYTES)

    # bring these variables out of the closure's scope, we'll use them a lot
    service = null
    username = null
    userPassword = null
    randomPassword = null
    state = null

    async.waterfall [
      (done) ->
        secureStore.getSecret(profile, storePassword, done)
      (secretData, done) ->
        {service, username, passwordData} = secretData
        {userPassword, randomPassword, state} = passwordData
        if state != states.STEADY_STATE
          logger("Unexpected profile state #{state} for profile #{profile}")
          done("Unexpected profile state #{state}")
          return

        isCreatingToken(profile, storePassword, token, done)
      (done) ->
        pwdAndToken = userPassword + token

        preResetTokenCb = (cb) ->
          isRevokingToken(profile, storePassword, nextPassword, cb)

        services.setToken service, username, randomPassword, pwdAndToken, \
                          nextPassword, done, preResetTokenCb, (err) ->
          if err?
            logger("Unexpected error when resetting token", err)
            tokenResetCb?(err)
            return

          isUsingRandomPassword(profile, storePassword, tokenResetCb)
      (done) ->
        isUsingToken(profile, storePassword, done)
    ], (err, res) ->
      if err?
        tokenSetCb(err)
        return

      tokenSetCb(null, token)


module.exports = ProfileManager
