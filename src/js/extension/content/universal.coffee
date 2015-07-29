###
Content script that can fill out and submit forms.
###

logging = require('../../lib/util/logging')
logger = logging.logger(['ext', 'cont', 'universal'])

logger("Universal content script executing!")


submit = (elementValues, submitElementId, cb) ->
  for id, val of elementValues
    document.getElementById(id).value = val

  document.getElementById(submitElementId).click()

  logger("Submitted form!")

  window.onbeforeunload = () ->
    cb?()

    # don't prevent the unload
    return null


chrome.runtime.onMessage.addListener (message, sender, response) ->
  logger("Processing new message!")
  {elementValues, submitElementId} = message

  submit(elementValues, submitElementId, response)

  # indicate async response by returning true
  return true
