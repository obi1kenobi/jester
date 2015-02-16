_set = _get = () ->
  throw new Error("Not overriden -- no implementation found")

Storage = (logging) ->
  _logger: logging.logger(["jester", "storage"])

  ###
  Store a key-value pair. On node.js, key-value pairs are ephemeral and lost
  with the session. In the browser, they are persisted in the HTML5 local store.
  ###
  set: _set

  ###
  Get a value for the given key, or return undefined if no value is associated
  with that key. Uses node.js ephemeral storage and browsers' HTML5 local store.
  ###
  get: _get

nodeSetup = () ->
  store = {}
  _set = (key, value) ->
    store[key] = value

  _get = (key) ->
    return store[key]

  logging = require('./util/logging')
  module.exports = Storage(logging)

browserSetup = () ->
  _set = (key, value) ->
    keyString = JSON.stringify({key})
    valueString = JSON.stringify({value})
    localStorage.setItem(keyString, valueString)

  _get = (key) ->
    keyString = JSON.stringify({key})
    value = localStorage.getItem(keyString)
    if value?
      value = JSON.parse(value).value
    return value

  define(['util/logging'], Storage)

if module?.exports?
  # export for node.js
  nodeSetup()
else
  # export for browser
  browserSetup()
