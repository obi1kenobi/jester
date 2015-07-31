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
        # HACK(predrag): Chrome doesn't seem to respect 'minimized'
        #                or focused: false when creating new window,
        #                but does respect them when updating the window
        updateOptions =
           focused: false
           state: 'minimized'
        chrome.windows.update windowObj.id, updateOptions, () ->
        windowIds.push(windowObj.id)
        return cb(null, windowObj.tabs[0].id)
    else
      logger("Using existing window...")
      tabOptions =
        windowId: windowIds[0]
        url: url

      chrome.tabs.create tabOptions, (tabObj) ->
        return cb(null, tabObj.id)

  submitForm: (tabid, elementValues, submitElement, cb) ->
    executeOptions =
      file: 'js/extension/content/universal.js'

    chrome.tabs.executeScript tabid, executeOptions, () ->
      submitOptions = {elementValues, submitElement}

      chrome.tabs.sendMessage tabid, submitOptions, () ->
        # TODO(predrag): Figure out a better way to detect end of auth
        #                processing, and remove this timeout
        setTimeout cb, 1500

  releaseAllTabs: (cb) ->
    if windowIds.length == 0
      return cb('No tabs to release!')

    oldWindowIds = windowIds
    windowIds = []
    logger("Releasing windows!")
    async.each oldWindowIds, (id, next) ->
      chrome.windows.remove id, next
    , cb


module.exports = Shim
