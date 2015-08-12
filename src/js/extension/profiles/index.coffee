async         = require('../../../deps/async')
logger        = require('../../lib/util/logging').logger(['ext', 'profiles'])
secureStore   = require('../../lib/secure_store')
secureRandom  = require('../../lib/crypto/secure_random')
constants     = require('../../lib/config/constants')
services      = require('../services')
states        = require('./states')
stateManager  = require('./state_manager')


stateNeedsRepair = (state) ->
  return state != states.STEADY_STATE

getPasswordOptions = (passwordData) ->
  {userPassword, randomPassword, token, state} = passwordData

  switch state
    when states.INITIALIZING
      return [userPassword, randomPassword]
    when states.CREATING_TOKEN
      return [randomPassword, userPassword + token]
    when states.USING_TOKEN
      return [userPassword + token]
    when states.REVOKING_TOKEN
      return [userPassword + token, randomPassword]
    when states.INVALID
      if token?
        return [userPassword, randomPassword, userPassword + token]
      else
        return [userPassword, randomPassword]
    else
      logger("Unexpected state in recovery: #{state}")
      return []

attemptProfileRepair = (profile, storePassword, profileData, cb) ->
  {service, username, passwordData} = profileData
  passwordOptions = getPasswordOptions(passwordData)

  async.detectSeries passwordOptions, (password, done) ->
    services.testPassword service, username, password, (err) ->
      done(!err?)
  , (correctPassword) ->
    if !correctPassword?
      stateManager.isInvalid profile, storePassword, (err, res) ->
        if err?
          return cb(err)
        logger("Repair failed for profile #{profile}")
        return cb(null, states.INVALID)
    else
      logger("Found a valid password for profile #{profile}")
      finishProfileRepair profile, storePassword, service, username, \
                          correctPassword, passwordData.userPassword, (err, res) ->
        if err?
          return cb(err)
        logger("Repair successful for profile #{profile}")
        return cb(null, states.STEADY_STATE)

finishProfileRepair = (profile, storePassword, service, \
                       username, currentPassword, userPassword, cb) ->
  randomPassword = secureRandom.getRandomPassword(constants.DEFAULT_PASSWORD_BYTES)
  publicData = secureStore.getPublic(profile)

  async.series [
    (done) ->
      # ensure that in the event of interruption of the repair process,
      # the current password is still stored (in this case, in the random password field)
      stateManager.isInitializing(profile, storePassword, service, publicData, \
                                  username, userPassword, currentPassword, done)
    (done) ->
      services.setup(service, username, currentPassword, randomPassword, done)
    (done) ->
      stateManager.isFinishedRepair(profile, storePassword, service, publicData, \
                                    username, userPassword, randomPassword, done)
  ], cb

extractProfileData = ({profile, profileData}, storePassword, cb) ->
  {service, username} = profileData
  state = profileData.passwordData.state
  if stateNeedsRepair(state)
    if state == states.INVALID
      process.nextTick () ->
        cb(null, {service, username, valid: false})
    else
      logger("Attempting to repair profile #{profile}")
      attemptProfileRepair profile, storePassword, profileData, (err, newstate) ->
        if err?
          logger("Unexpected error when repairing profile", err)
          # that profile still requires repair, swallow error and report invalid
          return cb(null, {service, username, valid: false})
        cb(null, {service, username, valid: !stateNeedsRepair(newstate)})
  else
    process.nextTick () ->
      cb(null, {service, username, valid: true})

ProfileManager =
  getAll: (storePassword, cb) ->
    profiles = secureStore.getProfileNames()

    async.waterfall [
      (done) ->
        async.map profiles, (profile, callb) ->
          secureStore.getSecret(profile, storePassword, callb)
        , done
      (result, done) ->
        allProfileData = []
        for i in [0...profiles.length]
          # TODO(predrag): Remove this call before publishing; only for testing purposes
          # console.error "ext:profiles: Profile #{profiles[i]}: " + \
          #               "#{JSON.stringify(result[i])}"

          allProfileData.push {profile: profiles[i], profileData: result[i]}

        async.mapSeries allProfileData, (item, callb) ->
          extractProfileData(item, storePassword, callb)
        , done
      (extractedData, done) ->
        result = {}
        for i in [0...profiles.length]
          result[profiles[i]] = extractedData[i]
        process.nextTick () ->
          done(null, result)
    ], cb

  createNew: (profile, storePassword, service, username, userPassword, cb) ->
    randomPassword = secureRandom.getRandomPassword(constants.DEFAULT_PASSWORD_BYTES)

    async.series [
      (done) ->
        # ensure the provided password is valid before we record any data
        services.testPassword(service, username, userPassword, done)
      (done) ->
        stateManager.isInitializing(profile, storePassword, service, {}, username, \
                                    userPassword, randomPassword, done)
      (done) ->
        services.setup(service, username, userPassword, randomPassword, done)
      (done) ->
        stateManager.isUsingRandomPassword(profile, storePassword, done)
    ], cb

  getToken: (profile, storePassword, tokenSetCb, tokenResetCb) ->
    token = secureRandom.getRandomNumericCode(constants.ONE_TIME_CODE_DIGITS)
    nextPassword = secureRandom.getRandomPassword(constants.DEFAULT_PASSWORD_BYTES)

    # bring these variables into the topmost function's scope, we'll use them a lot
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

        stateManager.isCreatingToken(profile, storePassword, token, done)
      (done) ->
        pwdAndToken = userPassword + token

        preResetTokenCb = (cb) ->
          stateManager.isRevokingToken(profile, storePassword, nextPassword, cb)

        services.setToken service, username, randomPassword, pwdAndToken, \
                          nextPassword, done, preResetTokenCb, (err) ->
          if err?
            logger("Unexpected error when resetting token", err)
            tokenResetCb?(err)
            return

          stateManager.isUsingRandomPassword(profile, storePassword, tokenResetCb)
      (done) ->
        stateManager.isUsingToken(profile, storePassword, done)
    ], (err, res) ->
      if err?
        tokenSetCb(err)
        return

      tokenSetCb(null, token)

  repair: (profile, storePassword, cb) ->
    async.waterfall [
      (done) ->
        secureStore.getSecret(profile, storePassword, done)
      (secretData, done) ->
        if stateNeedsRepair(secretData.passwordData.state)
          attemptProfileRepair(profile, storePassword, secretData, done)
        else
          process.nextTick () ->
            done(null, secretData.passwordData.state)
    ], (err, newstate) ->
      if err?
        cb(err)
      else
        cb(null, !stateNeedsRepair(newstate))


module.exports = ProfileManager
