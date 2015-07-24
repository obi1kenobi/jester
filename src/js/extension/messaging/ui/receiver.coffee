logger    = require('../../../lib/util/logging').logger(['ext', 'msg', 'ui', 'rcv'])
types     = require('./message_types')

messageHandlers = {}

messageListener = (message, sender, sendResponse) ->
  logger("Received message from #{JSON.stringify(sender)}")

  {type, args} = message
  if !messageHandlers[type]?
    msg = "Unexpected message type #{type} with args #{JSON.stringify(args)}"
    throw new Error(msg)

  messageHandlers[type](args, sendResponse)


Receiver =
  # handler format:
  #   addNewHandler = ({profile, username, password}, sendResponse) ->
  #   getTokenHandler = ({profile}, sendResponse) ->
  #   getProfilesHandler = ({hash of profileName: profileObj}, sendResponse) ->
  setup: (addNewHandler, getTokenHandler, getProfilesHandler) ->
    messageHandlers[types.ADD_NEW] = addNewHandler
    messageHandlers[types.GET_TOKEN] = getTokenHandler
    messageHandlers[types.GET_PROFILES] = getProfilesHandler

    chrome.runtime.onMessage.addListener messageListener


module.exports = Receiver
