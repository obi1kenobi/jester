logging = require('../lib/util/logging')
logger = logging.logger(["ext", "core"])

yahooInfo = require('../lib/config/domain').yahoo

initialize = () ->
  logger("Initializing...")
  chrome.runtime.onMessage.addListener messageListener

sendMessageToLoginScript = (tabId, elementIds, username, password, cb) ->
  chrome.tabs.sendMessage tabId, {elementIds, username, password}, cb

messageListener = (message, sender, response) ->
  logger("Received message: #{JSON.stringify(message)}")

  chrome.tabs.create {url: yahooInfo.login.url}, (tab) ->
    logger("Login tab created successfully, id=#{tab.id}")
    chrome.tabs.executeScript tab.id, {file: 'js/extension/content/login.js'}, () ->
      logger("Login content script injected")
      username = "<username_here>"
      password = "<password_here>"
      sendMessageToLoginScript tab.id, yahooInfo.login.args, username, password, () ->
        logger("Login content script finished executing")

initialize()
