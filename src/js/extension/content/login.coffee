###
Content script injected into login pages.
###

logging = require('../../lib/util/logging')
logger = logging.logger(['ext', 'cont', 'login'])

logger("Login content script executing!")

chrome.runtime.onMessage.addListener (message, sender, response) ->
  logger("Received message: #{JSON.stringify(message)}")
