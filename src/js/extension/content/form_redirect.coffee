###
Content script that can fill out and submit forms.
###

$ = require('../../../deps/jquery.min.js')
logging = require('../../lib/util/logging')
logger = logging.logger(['ext', 'cont', 'form-redir'])

logger("Form-redirect content script executing!")


executeFormSubmit = (input, submit, cb) ->
  for own id, value of input
    $(id).val(value)

  $(submit).click()

  logger("Submitted form!")

  window.onbeforeunload = () ->
    cb?()

    # don't prevent the unload
    return null


chrome.runtime.onMessage.addListener (message, sender, response) ->
  logger("Processing new message!")
  {input, submit} = message

  executeFormSubmit(input, submit, response)

  # indicate async response by returning true
  return true
