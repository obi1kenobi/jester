logger    = require('../../../lib/util/logging').logger(['ext', 'msg', 'ui', 'send'])
types     = require('./message_types')

sendMessage = (type, args, cb) ->
  message = {type, args}
  chrome.runtime.sendMessage message, cb


Sender =
  sendAddNewMessage: (profile, username, password, cb) ->
    args = {profile, username, password}
    type = types.ADD_NEW

    sendMessage(type, args, cb)

  sendGetTokenMessage: (profile, cb) ->
    args = {profile}
    type = types.GET_TOKEN

    sendMessage(type, args, cb)

  sendGetProfilesMessage: (cb) ->
    args = null
    type = types.GET_PROFILES

    sendMessage(type, args, cb)


module.exports = Sender
