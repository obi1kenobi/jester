logger      = require('../lib/util/logging').logger(['ext', 'core'])
receiver    = require('./messaging/ui/receiver')
secureStore = require('../lib/secure_store')

init = () ->
  setupHandlers()

setupHandlers = () ->
  addNewHandler = ({profile, username, password}, sendResponse) ->
    logger('received add-new message')
    sendResponse()

  getTokenHandler = ({profile}, sendResponse) ->
    logger('received get-token message')
    sendResponse()

  getProfilesHandler = (profilesObj, sendResponse) ->
    logger('received get-profiles message')
    sendResponse()

  receiver.setup(addNewHandler, getTokenHandler, getProfilesHandler)

init()
