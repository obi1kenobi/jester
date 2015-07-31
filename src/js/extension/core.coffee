logger      = require('../lib/util/logging').logger(['ext', 'core'])
receiver    = require('./messaging/ui/receiver')
types       = require('./messaging/ui/message_types')
secureStore = require('../lib/secure_store')
profiles    = require('./profiles')

init = () ->
  setupHandlers()
  setupBrowserAction()

setupBrowserAction = () ->
  chrome.browserAction.onClicked.addListener () ->
    options =
      url: chrome.extension.getURL('html/main.html')
      selected: true
    chrome.tabs.create(options)

setupHandlers = () ->
  addNewHandler = ({profile, storePassword, service, username, password}, \
                   sendResponse) ->
    logger('received add-new message')
    profiles.createNew(profile, storePassword, service, \
                       username, password, sendResponse)

  getTokenHandler = ({profile, storePassword}, sendResponse) ->
    logger('received get-token message')
    profiles.getToken profile, storePassword, sendResponse, (err, res) ->
      logger("Token reset cb, err=#{err} res=#{res}")

  getProfilesHandler = ({storePassword}, sendResponse) ->
    logger('received get-profiles message')
    profiles.getAll(storePassword, sendResponse)

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
