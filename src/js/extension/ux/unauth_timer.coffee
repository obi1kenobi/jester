logger          = require('../../lib/util/logging').logger(['ext', 'ux', 'unauth'])
constants       = require('../../lib/config/constants')


timer = null
tabid = null

closeTab = () ->
  chrome.tabs.remove(tabid)


UnauthTimer =
  setup: (tabid) ->
    logger("Setting unauth timer")
    timer = setTimeout(closeTab, (constants.AUTO_UNAUTH_SECONDS * 1000))

  reset: () ->
    logger("Resetting unauth timer")
    if timer?
      clearTimeout(timer)
      timer = setTimeout(closeTab, (constants.AUTO_UNAUTH_SECONDS * 1000))


module.exports = UnauthTimer
