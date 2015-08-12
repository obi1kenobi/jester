async            = require('../../../deps/async')
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

    aborted = false
    timeout = setTimeout () ->
      aborted = true
      fn = cb
      cb = null
      fn?("Submit aborted, no reply from injected script")
    , 5000

    chrome.tabs.sendMessage tabid, submitOptions, () ->
      retryOpts =
        times: 20
        interval: 200

      async.retry retryOpts, (done) ->
        if aborted
          return process.nextTick () ->
            done("Aborted")
        chrome.tabs.get tabid, (tab) ->
          if !tab.url?
            logger("Unexpected tab object with no URL")
            return done("Unexpected tab object with no URL")

          if onSuccessURL.test(tab.url)
            return done(null)
          else
            return done({expected: onSuccessURL, received: tab.url})
      , (err, res) ->
        clearTimeout(timeout)
        if !aborted
          fn = cb
          cb = null
          fn?(err, res)


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
