async           = require('../../../deps/async')
logger          = require('../../lib/util/logging').logger(['ext', 'svc'])
constants       = require('../../lib/config/constants')
serviceData     = require('./service_data')
shim            = require('./shim')
windowManager   = require('./window_manager')

login = (wnd, service, username, password, cb) ->
  # TODO(predrag): Remove this call before publishing; only for testing purposes
  # console.error "ext:svc: Logging into #{service} with password: #{password}"

  action = 'login'
  userInfo = {username, password}
  shim.submit(wnd, service, action, userInfo, cb)

# assumes the user is already logged in
changePassword = (wnd, service, currentPassword, newPassword, cb) ->
  # TODO(predrag): Remove this call before publishing; only for testing purposes
  # console.error "ext:svc: Changing #{service} password to: #{newPassword}"

  action = 'changePwd'
  userInfo =
    oldPassword: currentPassword
    newPassword: newPassword
    confirmPassword: newPassword
  shim.submit(wnd, service, action, userInfo, cb)

loginAndChangePassword = (service, username, currentPassword, newPassword, cb) ->
  wnd = windowManager.getWindow()

  async.series [
    (done) ->
      login(wnd, service, username, currentPassword, done)
    (done) ->
      changePassword(wnd, service, currentPassword, newPassword, done)
  ], (err) ->
    # all tabs should be released, regardless of success or error
    windowManager.releaseWindow wnd, () ->
      cb(err)

ServiceManager =
  setup: (service, username, currentPassword, randomPassword, cb) ->
    loginAndChangePassword(service, username, currentPassword, randomPassword, cb)

  testPassword: (service, username, password, cb) ->
    wnd = windowManager.getWindow()

    # HACK(predrag): Chrome seems to asynchronously scrub incognito data
    # so if an incognito window is closed, and then quickly opened again,
    # some of the data may still be present.
    # For the moment, attempt to mitigate that by delaying the login attempt
    # by half a second.
    setTimeout () ->
      login wnd, service, username, password, (err, res) ->
        windowManager.releaseWindow wnd, () ->
          cb(err, res)
    , 500

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
