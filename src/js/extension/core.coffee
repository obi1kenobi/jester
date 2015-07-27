logger      = require('../lib/util/logging').logger(['ext', 'core'])
receiver    = require('./messaging/ui/receiver')
types       = require('./messaging/ui/message_types')
secureStore = require('../lib/secure_store')

init = () ->
  setupHandlers()

setupHandlers = () ->
  addNewHandler = ({profile, storePassword, username, password}, sendResponse) ->
    logger('received add-new message -- not implemented')
    process.nextTick () ->
      sendResponse()

  getTokenHandler = ({profile, storePassword}, sendResponse) ->
    logger('received get-token message -- not implemented')
    process.nextTick () ->
      sendResponse()

  getProfilesHandler = ({storePassword}, sendResponse) ->
    logger('received get-profiles message -- not implemented')
    process.nextTick () ->
      sendResponse()

  configExistsHandler = ({}, sendResponse) ->
    logger('received config-exists message')
    process.nextTick () ->
      exists = secureStore.configExists()
      logger("exists: #{exists}")
      sendResponse(null, exists)

  getConfigHandler = ({storePassword}, sendResponse) ->
    logger('received get-config message')
    secureStore.getConfig(storePassword, sendResponse)

  setConfigHandler = ({storePassword, config}, sendResponse) ->
    logger('received set-config message')
    secureStore.setConfig(storePassword, config, sendResponse)

  handlers = {}
  handlers[types.ADD_NEW] = addNewHandler
  handlers[types.GET_TOKEN] = getTokenHandler
  handlers[types.GET_PROFILES] = getProfilesHandler
  handlers[types.CONFIG_EXISTS] = configExistsHandler
  handlers[types.GET_CONFIG] = getConfigHandler
  handlers[types.SET_CONFIG] = setConfigHandler

  receiver.setup(handlers)

init()
