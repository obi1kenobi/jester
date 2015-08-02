###
Content script that can fill out and submit forms.
###

$ = require('../../../deps/jquery.min.js')
logging = require('../../lib/util/logging')
logger = logging.logger(['ext', 'cont', 'form-redir'])

logger("Form-redirect content script executing!")


submit = (elementValues, submitElement, cb) ->
  for id, value of elementValues
    $(id).val(value)

  $(submitElement).click()

  logger("Submitted form!")

  window.onbeforeunload = () ->
    cb?()

    # don't prevent the unload
    return null


chrome.runtime.onMessage.addListener (message, sender, response) ->
  logger("Processing new message!")
  {elementValues, submitElement} = message

  submit(elementValues, submitElement, response)

  # indicate async response by returning true
  return true
