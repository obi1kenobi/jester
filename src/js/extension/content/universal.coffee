###
Content script that can fill out and submit forms.
###

logging = require('../../lib/util/logging')
logger = logging.logger(['ext', 'cont', 'universal'])

logger("Universal content script executing!")

executeLogin = (elementValues, submitElementId, cb) ->
  for id, val of elementValues
    document.getElementById(id).value = val

  document.getElementById(submitElementId).click()

  logger("Submitted form!")
  cb?()

chrome.runtime.onMessage.addListener (message, sender, response) ->
  logger("Processing new message!")
  {elementValues, submitElementId} = message
  executeLogin(elementValues, submitElementId, response)
