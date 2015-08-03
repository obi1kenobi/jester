logger           = require('../../lib/util/logging').logger(['ext', 'svc', 'shim'])
serviceData      = require('./service_data')
windowManager    = require('./window_manager')


formRedirectHandler = (tabid, args, userInfo, cb) ->
  {input, submit, onSuccessURL} = args
  scriptArgs = {}
  for own key, value of input
    if !userInfo[key]?
      logger("No user info provided for required field #{key}")
      return process.nextTick () ->
        cb("No user info provided for required field #{key}")

    scriptArgs[value] = userInfo[key]

  executeOptions =
    file: 'js/extension/content/form_redirect.js'

  chrome.tabs.executeScript tabid, executeOptions, () ->
    submitOptions =
      input: scriptArgs
      submit: submit

    chrome.tabs.sendMessage tabid, submitOptions, () ->
      # TODO(predrag): Figure out if the timeout for server
      #                processing / redirect can be avoided
      setTimeout () ->
        chrome.tabs.get tabid, (tab) ->
          if !tab.url?
            logger("Unexpected tab object with no URL")
            cb("Unexpected tab object with no URL")
            return

          if onSuccessURL.test(tab.url)
            cb(null)
            return
          else
            error = {expected: onSuccessURL, received: tab.url}
            logger("Error submitting form: expected #{onSuccessURL}, got #{tab.url}")
            cb(error)
            return
      , 1500


handlers = {}
handlers['form_redirect'] = formRedirectHandler


Shim =
  submit: (wnd, service, action, userInfo, cb) ->
    data = serviceData[service]?[action]
    if !data?
      logger("Bad service or action: #{service} -> #{action}")
      return process.nextTick () ->
        cb("Bad service or action: #{service} -> #{action}")

    {url, type, args} = data

    if !handlers[type]?
      logger("No handler for submit type #{type}")
      return process.nextTick () ->
        cb("No handler for submit type #{type}")

    windowManager.getTab wnd, url, (err, tabid) ->
      if err?
        return cb(err)
      handlers[type](tabid, args, userInfo, cb)


module.exports = Shim
