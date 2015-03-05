###
Content script injected into login pages.
###

logging = require('../../lib/util/logging')
logger = logging.logger(['ext', 'cont', 'login'])

logger("Login content script executing!")

executeLogin = (elementIds, username, password, cb) ->
  document.getElementById(elementIds.usernameId).value = username
  document.getElementById(elementIds.passwordId).value = password
  document.getElementById(elementIds.submitId).click()
  logger("Executed login!")
  cb?()

chrome.runtime.onMessage.addListener (message, sender, response) ->
  logger("Processing new message!")
  {elementIds, username, password} = message
  executeLogin(elementIds, username, password, response)
