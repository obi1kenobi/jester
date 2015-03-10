logging   = require('../lib/util/logging')
logger    = logging.logger(["ext", "core"])
constants = require('./constants')

yahooInfo = require('../lib/config/domain').yahoo

messageHandlers = {}

initialize = () ->
  logger("Initializing...")
  messageHandlers[constants.LOGIN_MESSAGE] = loginMessageHandler
  messageHandlers[constants.SETUP_MESSAGE] = setupMessageHandler
  messageHandlers[constants.GENCODE_MESSAGE] = genCodeMessageHandler
  chrome.runtime.onMessage.addListener messageListener

sendMessageToLoginScript = (tabId, elementIds, username, password, cb) ->
  chrome.tabs.sendMessage tabId, {elementIds, username, password}, cb

messageListener = (message, sender, response) ->
  logger("Received message: #{JSON.stringify(message)}")

  {type, args} = message
  if !messageHandlers[type]?
    throw new Error("Unexpected message type #{type} with args #{JSON.stringify(args)}")

  messageHandlers[type](args)

loginMessageHandler = (args) ->
  chrome.tabs.create {url: yahooInfo.login.url}, (tab) ->
    logger("Login tab created successfully, id=#{tab.id}")
    chrome.tabs.executeScript tab.id, {file: 'js/extension/content/login.js'}, () ->
      logger("Login content script injected")
      {username, password} = args
      sendMessageToLoginScript tab.id, yahooInfo.login.args, username, password, () ->
        logger("Login content script finished executing")

setupMessageHandler = (args) ->
  logger('Setup message handler not implemented yet')

genCodeMessageHandler = (args) ->
  logger('GenCode message handler not implemented yet')

initialize()
