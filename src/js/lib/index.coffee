logging   = require('./util/logging')
logger    = logging.logger(["lib", "index"])
storage   = require('./storage')

shim = null

###
A library that allows client-side-only use of two-factor authentication (2FA).

Terminology:
  username        = the name of the user for the given service
  user_password   = the password the user is using for the service
  random_password = the randomly-generated password Jester uses for server login
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
  @param  user_password    {String}   the user's password
  @param  cb               {function} (Optional) callback when initialization is done
  ###
  initNewService: (service, username, user_password, cb) ->
    throw new Error("Not implemented")

  ###
  Get a 2FA token that can be used to login on another device.
  Should be called on the 2FA device (same one where init() was called).

  @param  service          {String}   the service for which to setup 2FA
  @param  username         {String}   the username for which to setup 2FA
  @param  user_password    {String}   the user's password
  @param  cb               {function} (error, 2FAtoken) callback
  ###
  getToken: (service, username, user_password, cb) ->
    throw new Error("Not implemented")

  ###
  Login to the given service using the username, user password and token specified.

  @param  service          {String}   the service for which to setup 2FA
  @param  username         {String}   the username for which to setup 2FA
  @param  user_password    {String}   the user's password
  @param  token            {String}   the 2FA token to use to log in
  @param  cb               {function} (Optional) callback when login is complete
  ###
  login: (service, username, user_password, token, cb) ->
    throw new Error("Not implemented")

  ###
  Change the user's password for the given service, setting it from
  user_password to new_user_password.

  @param  service           {String}   the service for which to setup 2FA
  @param  username          {String}   the username for which to setup 2FA
  @param  user_password     {String}   the user's current password
  @param  new_user_password {String}   the user's new password
  @param  cb                {function} (Optional) callback when the change is complete
  ###
  changeUserPassword: (service, username, user_password, new_user_password, cb) ->
    throw new Error("Not implemented")


module.exports = Jester
