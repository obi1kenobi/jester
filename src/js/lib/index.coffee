logging   = require('./util/logging')
logger    = logging.logger(["lib", "index"])

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
  Initialize the 2FA scheme, with the device
  this method is called on as the 2FA second factor.

  @param  service          {String} the service for which to setup 2FA
  @param  username         {String} the username for which to setup 2FA
  @param  user_password    {String} the user's password
  ###
  init: (service, username, user_password) ->
    throw new Error("Not implemented")

  ###
  Get a 2FA token that can be used to login on another device.
  Should be called on the 2FA device (same one where init() was called).

  @param  service          {String} the service for which to setup 2FA
  @param  username         {String} the username for which to setup 2FA
  @param  user_password    {String} the user's password
  @return                  {String} the 2FA token to use when logging in
  ###
  getToken: (service, username, user_password) ->
    throw new Error("Not implemented")

  ###
  Login to the given service using the username, user password and token specified.

  @param  service          {String} the service for which to setup 2FA
  @param  username         {String} the username for which to setup 2FA
  @param  user_password    {String} the user's password
  @param  token            {String} the 2FA token to use to log in
  @return                 {Boolean} whether login succeeded or not
  ###
  login: (service, username, user_password, token) ->
    throw new Error("Not implemented")

  ###
  Change the user's password for the given service, setting it from
  user_password to new_user_password.

  @param  service           {String} the service for which to setup 2FA
  @param  username          {String} the username for which to setup 2FA
  @param  user_password     {String} the user's current password
  @param  new_user_password {String} the user's new password
  ###
  changeUserPassword: (service, username, user_password, new_user_password) ->
    throw new Error("Not implemented")


module.exports = Jester
