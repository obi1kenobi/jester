logging = require('../lib/util/logging')
logger = logging.logger(["ext", "core"])
Core =
  start: () ->
    logger("Hello world!")

  # inject the content script into the currently active tab
  injectContentScript: () ->
    chrome.tabs.executeScript {file: './content.js'}
