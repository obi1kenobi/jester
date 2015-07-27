logger    = require('../../../lib/util/logging').logger(['ext', 'msg', 'ui', 'send'])
types     = require('./message_types')

sendMessage = (type, args, cb) ->
  message = {type, args}

  # Chrome allows only a single argument in the response callback.
  # Hence, note the {err, res} unwrapping.
  chrome.runtime.sendMessage message, ({err, res}) ->
    cb(err, res)


Sender =
  sendAddNewMessage: (profile, storePassword, service, username, password, cb) ->
    args = {profile, storePassword, service, username, password}
    type = types.ADD_NEW

    sendMessage(type, args, cb)

  sendGetTokenMessage: (profile, storePassword, cb) ->
    args = {profile, storePassword}
    type = types.GET_TOKEN

    sendMessage(type, args, cb)

  sendGetProfilesMessage: (storePassword, cb) ->
    args = {storePassword}
    type = types.GET_PROFILES

    sendMessage(type, args, cb)

  sendConfigExistsMessage: (cb) ->
    args = null
    type = types.CONFIG_EXISTS

    sendMessage(type, args, cb)

  sendGetConfigMessage: (storePassword, cb) ->
    args = {storePassword}
    type = types.GET_CONFIG

    sendMessage(type, args, cb)

  sendSetConfigMessage: (storePassword, config, cb) ->
    args = {storePassword, config}
    type = types.SET_CONFIG

    sendMessage(type, args, cb)

module.exports = Sender
