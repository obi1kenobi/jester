logger        = require('../../lib/util/logging').logger(['ext', 'profiles'])
secureStore   = require('../../lib/secure_store')
secureRandom  = require('../../lib/crypto/secure_random')
constants     = require('../../lib/config/constants')
services      = require('../services')

states =

  # ### State flow: ###
  #
  # - new user account created:           INITIALIZING
  #                                            \/
  # - changed password to random:         STEADY_STATE  <---+
  #                                            \/           |
  # - requested token:                   CREATING_TOKEN     |
  #                                            \/           | (token
  # - token created successfully:          USING_TOKEN      |  successfully
  #                                            \/           |  revoked)
  # - token about to be revoked:         REVOKING_TOKEN ----+
  #
  # - when Jester couldn't find              INVALID
  #   a valid password to repair to
  #
  #
  # When profiles are loaded, all of them should be in STEADY_STATE or INVALID.
  # Any accounts that are not in one of these states require repair. One of the ways
  # this could happen is if the browser was closed while Jester was in the middle
  # of a password change operation. Repair proceeds as follows:
  # 1. Depending on the current state of the profile, possible password candidates
  #    are identified.
  # 2. Login is attempted with each password candidate.
  # 3. If no working password is discovered among the candidates, the profile
  #    is marked INVALID and the repair process is terminated.
  #    If a working password is discovered, the profile is marked INITIALIZING
  #    and the working password is set as the 'random password' of the profile.
  #    This ensures that any interruption during repair will not result in the
  #    working password being removed before being changed successfully.
  # 4. A new random password is generated and set on the account corresponding
  #    to the profile.
  # 5. The profile is set to STEADY_STATE.
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

  # none of the possible passwords are accepted as valid
  # could only occur as a result of user action
  # (e.g. the user manually changing their password on a service
  #  without updating the account info in Jester)
  INVALID: 'invalid'


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

isInvalid = (profile, storePassword, cb) ->
  update = (secretData) ->
    {passwordData} = secretData
    passwordData.state = states.INVALID

    secretData.passwordData = passwordData
    return secretData
  updateProfile(profile, storePassword, update, cb)

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
      return []
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
      isInvalid profile, storePassword, (err, res) ->
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

  passwordData = {userPassword, randomPassword, state: states.STEADY_STATE}
  profileData = {service, username, passwordData}

  tempPasswordData =
    userPassword: userPassword
    randomPassword: currentPassword
    state: states.INITIALIZING
  tempProfileData = {service, username, passwordData: tempPasswordData}

  async.series [
    (done) ->
      # ensure that in the event of interruption of the repair process,
      # the current password is still stored (in this case, in the random password field)
      secureStore.setProfile(profile, storePassword, publicData, tempProfileData, done)
    (done) ->
      services.setup(service, username, currentPassword, randomPassword, done)
    (done) ->
      secureStore.setProfile(profile, storePassword, publicData, profileData, done)
  ], cb

extractProfileData = ({profile, profileData}, storePassword, cb) ->
  {service, username} = profileData
  state = profileData.passwordData.state
  if stateNeedsRepair(state)
    logger("Attempting to repair profile #{profile}")
    attemptProfileRepair profile, storePassword, profileData, (err, newstate) ->
      if err?
        logger("Unexpected error when repairing profile", err)
        return cb("Unexpected error when repairing profile: #{err}")
      cb(null, {service, username, valid: stateNeedsRepair(newstate)})
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
