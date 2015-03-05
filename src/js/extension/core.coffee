logging = require('../lib/util/logging')
logger = logging.logger(["ext", "core"])

yahooInfo = require('../lib/config/domain').yahoo

initialize = () ->
  logger("Initializing...")
  chrome.runtime.onMessage.addListener messageListener

messageListener = (message, sender, response) ->
  logger("Received message: #{JSON.stringify(message)}")

  chrome.tabs.create {url: yahooInfo.login.url}, (tab) ->
    logger("Login tab created successfully, id=#{tab.id}")
    chrome.tabs.executeScript tab.id, {file: 'js/extension/content/login.js'}, () ->
      logger("Login content script injected")
      message = "Hello world!"
      chrome.tabs.sendMessage tab.id, message

initialize()
