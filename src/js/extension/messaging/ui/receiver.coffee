logger    = require('../../../lib/util/logging').logger(['ext', 'msg', 'ui', 'rcv'])
types     = require('./message_types')

messageHandlers = {}

messageListener = (message, sender, sendResponse) ->
  {type, args} = message
  if !messageHandlers[type]?
    msg = "Unexpected message type #{type} with args #{JSON.stringify(args)}"
    throw new Error(msg)

  messageHandlers[type] args, (err, res) ->
    # Chrome allows only a single argument in the response callback.
    # Note the {err, res} wrapping into a single object.
    sendResponse({err, res})

  # return true to indicate async response
  return true


Receiver =
  # handlers is an Object containing a handler for each message type
  # handler format:
  #   ADD_NEW = ({profile, storePassword, username, password}, sendResponse) ->
  #   GET_TOKEN = ({profile, storePassword}, sendResponse) ->
  #   GET_PROFILES = ({storePassword}, sendResponse) ->
  #   CONFIG_EXISTS = ({}, sendResponse) ->
  #   GET_CONFIG = ({storePassword}, sendResponse) ->
  #   SET_CONFIG = ({storePassword, config}, sendResponse) ->
  setup: (handlers) ->
    for key in Object.keys(types)
      type = types[key]
      messageHandlers[type] = handlers[type]

    chrome.runtime.onMessage.addListener messageListener


module.exports = Receiver
