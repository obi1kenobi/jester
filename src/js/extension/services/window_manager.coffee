logger    = require('../../lib/util/logging').logger(['ext', 'svc', 'window'])

# Windows are not safe for concurrent use.
# No method with a window parameter may be called before the callback
#   of an existing method call with the same window is called and completed.
WindowManager =
  getWindow: () ->
    wnd =
      id: null
    return wnd

  getTab: (wnd, url, cb) ->
    if wnd.id?
      logger("Adding a tab to window id #{wnd.id}")
      tabOptions =
        windowId: wnd.id
        url: url
      chrome.tabs.create tabOptions, (tabObj) ->
        cb(null, tabObj.id)
        return
    else
      # TODO(predrag): Make a note that "Allow in incognito"
      #                must be checked for the extension to work

      # Chrome seems to not respect minimized or focused when creating
      # a new window, so we'll have to apply them after the fact too
      windowOptions =
        url: url
        focused: false
        incognito: true
        state: 'minimized'

      chrome.windows.create windowOptions, (windowObj) ->
        windowId = windowObj.id

        if !windowId?
          logger("Unexpectedly received a window with no ID")
          return cb("Unexpectedly received a window with no ID")

        wnd.id = windowId
        logger("Created a new window with id #{wnd.id}")

        updateOptions =
          focused: false
          state: 'minimized'
        chrome.windows.update windowId, updateOptions, () ->
          cb(null, windowObj.tabs[0].id)
          return

  releaseWindow: (wnd, cb) ->
    if wnd.id?
      logger("Removing window with id #{wnd.id}")
      chrome.windows.remove wnd.id, cb
    else
      process.nextTick cb


module.exports = WindowManager
