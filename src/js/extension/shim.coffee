logging   = require('../lib/util/logging')
logger    = logging.logger(["ext", "shim"])

module.exports = (url, elementValues, submitElementId, cb) ->
  logger("Shim submitting data to #{url}")
  timeoutDuration = 20
  chrome.tabs.create {url}, (tab) ->
    logger("Tab created successfully, id=#{tab.id}")
    window.setTimeout () ->
      chrome.tabs.executeScript tab.id, {file: 'js/extension/content/universal.js'}, () ->
        chrome.tabs.sendMessage tab.id, {elementValues, submitElementId}, cb
    , timeoutDuration
