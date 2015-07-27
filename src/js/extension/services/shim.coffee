logger    = require('../../lib/util/logging').logger(['ext', 'svc', 'shim'])

windowIds = []

Shim =
  getTab: (url, cb) ->
    if windowIds.length == 0
      logger("Creating new window...")
      # TODO(predrag): Make a note that "Allow in incognito"
      #                must be checked for the extension to work
      windowOptions =
        url: url
        focused: false
        incognito: true
        state: 'minimized'

      chrome.windows.create windowOptions, (windowObj) ->
        windowIds.push(windowObj.id)
        return cb(null, windowObj.tabs[0].id)
    else
      logger("Using existing window...")
      tabOptions =
        windowId: windowIds[0]
        url: url

      chrome.tabs.create tabOptions, (tabObj) ->
        return cb(null, tabObj.id)

  submitForm: (tabid, elementValues, submitElementId, cb) ->
    executeOptions =
      file: 'js/extension/content/universal.js'

    chrome.tabs.executeScript tabid, executeOptions, () ->
      submitOptions = {elementValues, submitElementId}

      chrome.tabs.sendMessage tabid, submitOptions, cb

  releaseAllTabs: (cb) ->
    if windowIds.length == 0
      return cb('No tabs to release!')

    async.each windowIds, (id, next) ->
      chrome.windows.remove id, next
    , cb


module.exports = Shim
