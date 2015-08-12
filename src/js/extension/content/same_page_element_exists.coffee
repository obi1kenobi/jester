$ = require('../../../deps/jquery.min.js')
logging = require('../../lib/util/logging')
logger = logging.logger(['ext', 'cont', 'same-elem'])

logger("Same-page-element-exists content script executing!")


executeFormSubmit = (input, submit, onSuccessElement, cb) ->
  for own id, value of input
    if $(id).length == 0
      logger("No element matching selector #{id} found!")
      return cb("No element '#{id}' found")

    $(id).val(value)

  if $(submit).length == 0
    logger("No element matching selector #{submit} found!")
    return cb("No element '#{submit}' found")

  $(submit).click()

  logger("Submitted form!")

  interval = setInterval () ->
    if $(onSuccessElement).length > 0
      clearInterval(interval)
      fn = cb
      cb = null
      fn?()
  , 100


chrome.runtime.onMessage.addListener (message, sender, response) ->
  logger("Processing new message!")
  {input, submit, onSuccessElement} = message

  executeFormSubmit(input, submit, onSuccessElement, response)

  # indicate async response by returning true
  return true
