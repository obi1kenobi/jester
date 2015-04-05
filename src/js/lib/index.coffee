logging     = require('./util/logging')
logger      = logging.logger(["lib", "index"])
passwords   = require('./passwords')
serviceData = require('./config/service')
crypto      = require('./crypto/proxies')
constants   = require('./config/constants')

shim = null

###
Use the specified username and password to login into the specified service.
###
loginWithUsernameAndPassword = (service, username, password, cb) ->
  try
    data = serviceData.getInfo(service)?.login
  catch err
    logger("Service #{service} not found:", err)
    return cb?(err)
  url = data.url
  {usernameId, passwordId, submitId} = data.args
  submitData = {}
  submitData[usernameId] = username
  submitData[passwordId] = password
  shim(url, submitData, submitId, cb)

###
After the user is already logged in, change their password to a new one.
###
changePassword = (service, newPassword, cb) ->
  try
    data = serviceData.getInfo(service)?.changePwd
  catch err
    logger("Service #{service} not found:", err)
    return cb?(err)
  url = data.url
  {passwordId, confirmPasswordId, submitId} = data.args
  submitData = {}
  submitData[passwordId] = newPassword
  submitData[confirmPasswordId] = newPassword
  console.error "Setting password to: #{newPassword}"
  shim(url, submitData, submitId, cb)

###
Reset the user's password to a new random password,
both online and in the local registry.

Assumes the user is already logged in.
###
resetToRandomPassword = (service, userPassword, cb) ->
  passwords.setRandomPassword service, userPassword, (err, randomPassword) ->
    if err?
      cb?(err)
    else
      changePassword service, randomPassword, cb

###
A library that allows client-side-only use of two-factor authentication (2FA).

Terminology:
  username        = the name of the user for the given service
  userPassword    = the password the user is using for the service
  randomPassword  = the randomly-generated password Jester uses for server login
  service         = the service (website) that Jester is being used with
###
Jester =

  ###
  Jester depends on a browser-specific shim that allows it to fill out
  and submit forms on various URLs in order to log in and change passwords.
  This function must be called before any other function from Jester.

  The shim is a function with signature:
    (url, elementValues, submitElementId, cb) where
      url               {String} url where to form is found
      elementValues     {Object} mapping of element ID -> value to set it to
      submitElementId   {String} ID of the element that submits the form when clicked
      cb                {function} (Optional) callback when form was submitted
  ###
  registerShim: (newShim) ->
    if !newShim?
      throw new Error("Cannot register null or undefined shim!")
    shim = newShim

  ###
  Initialize the 2FA scheme, with the device
  this method is called on as the 2FA second factor.

  @param  service          {String}   the service for which to setup 2FA
  @param  username         {String}   the username for which to setup 2FA
  @param  userPassword     {String}   the user's password
  @param  cb               {function} (Optional) callback when initialization is done
  ###
  initNewService: (service, username, userPassword, cb) ->
    loginWithUsernameAndPassword service, username, userPassword, (err, res) ->
      if err?
        logger("Error when initializing on service #{service}:", err)
        return cb?(err)
      else
        resetToRandomPassword service, userPassword, (err, res) ->
          if err?
            logger("Error when initializing on service #{service}:", err)
          return cb?(err, res)

  ###
  Login locally to the given service using the username specified,
  and using the saved random password, decrypted with the given user password.

  @param  service          {String}   the service for which to setup 2FA
  @param  username         {String}   the username for which to setup 2FA
  @param  userPassword     {String}   the user's password
  @param  cb               {function} (Optional) callback when login is complete
  ###
  login: (service, username, userPassword, cb) ->
    passwords.getPassword service, userPassword, (err, randomPassword) ->
      if err?
        logger("Error when logging into service #{service}:", err)
        return cb?(err)
      else
        loginWithUsernameAndPassword service, username, randomPassword, (err, res) ->
          if err?
            logger("Error when logging into service #{service}:", err)
          return cb?(err)

  ###
  Get a 2FA token that can be used to login on another device.
  Should be called on the 2FA device (same one where init() was called).

  @param  service          {String}   the service for which to setup 2FA
  @param  username         {String}   the username for which to setup 2FA
  @param  userPassword     {String}   the user's password
  @param  resetCallback    {function} () callback after the password is reset back
                                      not called if the other callback returned an error
  @param  cb               {function} (error, 2FAtoken) callback after the password is set
  ###
  getToken: (service, username, userPassword, resetCallback, cb) ->
    Jester.login service, username, userPassword, (err) ->
      if err?
        logger("Error when getting token for service #{service}:", err)
      else
        token = crypto.generateOneTimeCode()
        temporaryPassword = userPassword + token
        changePassword service, temporaryPassword, (err, res) ->
          if err?
            logger("Error when getting token for service #{service}:", err)
            return cb?(err, res)
          else
            console.error 'Temporary password:', temporaryPassword

            # set the timeout for resetting the password before calling the callback
            setTimeout () ->
              loginWithUsernameAndPassword service, username, temporaryPassword, (err, res) ->
                if err?
                  logger("Error when resetting temp password for service #{service}:", err)
                  return resetCallback?(err)
                else
                  resetToRandomPassword service, userPassword, (err, res) ->
                    if err?
                      logger("Error when resetting temp password for service #{service}:", err)
                    return resetCallback?(err)
            , constants.TEMPORARY_PASSWORD_VALIDITY_MS

            cb?(null, token)

  ###
  Change the user's password for the given service, setting it from
  userPassword to newUserPassword.

  @param  service           {String}   the service for which to setup 2FA
  @param  username          {String}   the username for which to setup 2FA
  @param  userPassword      {String}   the user's current password
  @param  newUserPassword   {String}   the user's new password
  @param  cb                {function} (Optional) callback when the change is complete
  ###
  changeUserPassword: (service, username, userPassword, newUserPassword, cb) ->
    passwords.changeEncryptionPassword service, userPassword, newUserPassword, (err, res) ->
      if err?
        logger("Error when changing password for service #{service}:", err)
      cb?(err, res)


module.exports = Jester
