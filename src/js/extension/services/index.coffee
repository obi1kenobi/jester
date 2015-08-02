logger      = require('../../lib/util/logging').logger(['ext', 'svc'])
constants   = require('../../lib/config/constants')
serviceData = require('./service_data')
shim        = require('./shim')

login = (service, username, currentPassword, cb) ->
  logger("Logging in with service #{service}")

  # TODO(predrag): Remove this call before publishing; only for testing purposes
  # console.error "ext:svc: Logging into #{service} with password: #{currentPassword}"

  data = serviceData[service].login
  submitElement = data.args.submit
  successUrlRegex = data.args.onSuccessURL
  elementValues = {}
  elementValues[data.args.username] = username
  elementValues[data.args.password] = currentPassword

  async.waterfall [
    (done) ->
      shim.getTab(data.url, done)
    (tabid, done) ->
      shim.submitForm(tabid, elementValues, submitElement, successUrlRegex, done)
  ], cb

# assumes the user is already logged in
changePassword = (service, currentPassword, newPassword, cb) ->
  # TODO(predrag): Remove this call before publishing; only for testing purposes
  # console.error "ext:svc: Changing #{service} password to: #{newPassword}"

  data = serviceData[service].changePwd
  submitElement = data.args.submit
  successUrlRegex = data.args.onSuccessURL
  elementValues = {}

  {oldPassword, password, confirmPassword} = data.args
  if oldPassword?
    elementValues[oldPassword] = currentPassword
  if password?
    elementValues[password] = newPassword
  if confirmPassword?
    elementValues[confirmPassword] = newPassword

  async.waterfall [
    (done) ->
      shim.getTab(data.url, done)
    (tabid, done) ->
      shim.submitForm(tabid, elementValues, submitElement, successUrlRegex, done)
  ], cb

loginAndChangePassword = (service, username, currentPassword, newPassword, cb) ->
  async.series [
    (done) ->
      login(service, username, currentPassword, done)
    (done) ->
      changePassword(service, currentPassword, newPassword, done)
  ], (err) ->
    # all tabs should be released, regardless of success or error
    shim.releaseAllTabs () ->
      cb(err)

ServiceManager =
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
