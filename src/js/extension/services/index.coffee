logger      = require('../../lib/util/logging').logger(['ext', 'svc'])
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


ServiceManager =
  # TODO(predrag): temporary visibility for testing purposes
  login: login

  setup: (service, username, userPassword, randomPassword, cb) ->
    async.series [
      (done) ->
        login(service, username, userPassword, done)
      (done) ->
        changePassword(service, randomPassword, done)
    ], (err, res) ->
      # all tabs should be released, regardless of success or error
      shim.releaseAllTabs () ->
        cb(err, res)


module.exports = ServiceManager
