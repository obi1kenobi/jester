logging    = require('./util/logging')
logger      = logging.logger(["lib", "index"])
passwords   = require('./passwords')
serviceData = require('./config/service')

shim = null

###
Use the specified username and password to login into the specified service.
###
loginWithUsernameAndPassword = (service, username, password, cb) ->
  try
    data = serviceData.getInfo(service)
  catch err
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
    data = serviceData.getInfo(service)
  catch err
    return cb?(err)
  url = data.url
  {passwordId, confirmPasswordId, submitId} = data.args
  submitData = {}
  submitData[passwordId] = newPassword
  submitData[confirmPasswordId] = newPassword
  shim(url, submitData, submitId, cb)

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
        passwords.setRandomPassword service, userPassword, (err, randomPassword) ->
          if err?
            logger("Error when initializing on service #{service}:", err)
            return cb?(err)
          else
            changePassword service, randomPassword, (err, res) ->
              if err?
                logger("Error when initializing on service #{service}:", err)
              cb?(err, res)

  ###
  Get a 2FA token that can be used to login on another device.
  Should be called on the 2FA device (same one where init() was called).

  @param  service          {String}   the service for which to setup 2FA
  @param  username         {String}   the username for which to setup 2FA
  @param  userPassword     {String}   the user's password
  @param  cb               {function} (error, 2FAtoken) callback
  ###
  getToken: (service, username, userPassword, cb) ->
    throw new Error("Not implemented")

  # ###
  # Login to the given service using the username, user password and token specified.

  # @param  service          {String}   the service for which to setup 2FA
  # @param  username         {String}   the username for which to setup 2FA
  # @param  userPassword     {String}   the user's password
  # @param  token            {String}   the 2FA token to use to log in
  # @param  cb               {function} (Optional) callback when login is complete
  # ###
  # login: (service, username, userPassword, token, cb) ->
  #   throw new Error("Not implemented")

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
    throw new Error("Not implemented")


module.exports = Jester
