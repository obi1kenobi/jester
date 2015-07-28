logger      = require('../../lib/util/logging').logger(['ext', 'svc'])
constants   = require('../../lib/config/constants')
serviceData = require('./service_data')
shim        = require('./shim')

login = (service, username, currentPassword, cb) ->
  logger("Logging in with service #{service}")
  data = serviceData[service].login
  submitElementId = data.args.submitId
  elementValues = {}
  elementValues[data.args.usernameId] = username
  elementValues[data.args.passwordId] = currentPassword

  async.waterfall [
    (done) ->
      shim.getTab(data.url, done)
    (tabid, done) ->
      shim.submitForm(tabid, elementValues, submitElementId, done)
  ], cb

# assumes the user is already logged in
changePassword = (service, newPassword, cb) ->
  data = serviceData[service].changePwd
  submitElementId = data.args.submitId
  elementValues = {}
  elementValues[data.args.passwordId] = newPassword
  elementValues[data.args.confirmPasswordId] = newPassword

  async.waterfall [
    (done) ->
      shim.getTab(data.url, done)
    (tabid, done) ->
      shim.submitForm(tabid, elementValues, submitElementId, done)
  ], cb

loginAndChangePassword = (service, username, currentPassword, newPassword, cb) ->
  async.series [
    (done) ->
      login(service, username, userPassword, done)
    (done) ->
      changePassword(service, newPassword, done)
  ], (err) ->
    # all tabs should be released, regardless of success or error
    shim.releaseAllTabs () ->
      cb(err)

ServiceManager =
  # TODO(predrag): temporary visibility for testing purposes
  login: login

  setup: (service, username, userPassword, randomPassword, cb) ->
    loginAndChangePassword(service, username, userPassword, randomPassword, cb)

  setToken: (service, username, currentPassword, pwdAndToken, \
             nextPassword, tokenSetCb, tokenPreResetCb, tokenResetCb) ->
    loginAndChangePassword service, username, currentPassword, pwdAndToken, (err) ->
      if err?
        tokenSetCb(err)
        return

      tokenSetCb()
      timeoutFn = () ->
        tokenPreResetCb (err) ->
          if err?
            logger("Unexpected error returned by callback of tokenPreResetCb")
            tokenResetCb(err)
            return

          loginAndChangePassword(service, username, pwdAndToken, \
                                 nextPassword, tokenResetCb)

      setTimeout(timeoutFn, constants.TEMPORARY_PASSWORD_VALIDITY_MS)


module.exports = ServiceManager
