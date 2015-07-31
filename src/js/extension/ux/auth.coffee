logger = require('../../lib/util/logging').logger(['ext', 'ux', 'auth'])

authCleanup = () ->
  logger("Cleaning up auth...")
  $('#jester-auth').addClass('hidden')
  $('#jester-authed').removeClass('hidden')

getSetupSubmitHandler = (sender, authFinishedCb) ->
  return (event) ->
    # we never want to leave the page,
    # or the extension popup will close
    event.preventDefault()

    password = $('#auth-setup-password').val()
    confirmPassword = $('#auth-setup-confpassword').val()

    if password != confirmPassword
      logger('Entered passwords do not match!')
      # TODO(predrag): add visual indication of password mismatch
      return false

    logger('Passwords match, setting up...')
    sender.sendSetConfigMessage password, {}, (err) ->
      if err?
        logger('Received error on sendSetConfigMessage', err)
        return
      else
        authCleanup()
        authFinishedCb(null, password)
        return

getAuthSubmitHandler = (sender, authFinishedCb) ->
  return (event) ->
    # we never want to leave the page,
    # or the extension popup will close
    event.preventDefault()
    password = $('#auth-password').val()
    sender.sendGetConfigMessage password, (err, config) ->
      if err?
        logger("Received error on sendGetConfigMessage, " + \
               "likely wrong password", err)
        # TODO(predrag): add visual indication of incorrect password
        return false
      else
        authCleanup()
        authFinishedCb(null, password)
        return


Auth =
  setup: (sender, authFinishedCb) ->
    sender.sendConfigExistsMessage (err, exists) ->
      if err?
        logger('Received error on sendConfigExistsMessage', err)
        return

      if exists
        $('#jester-enter').removeClass('hidden')
        $('#auth-creds').submit(getAuthSubmitHandler(sender, authFinishedCb))
      else
        $('#jester-setup').removeClass('hidden')
        $('#auth-setup-creds').submit(getSetupSubmitHandler(sender, authFinishedCb))


module.exports = Auth
