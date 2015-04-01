logger = require('./util/logging').logger(['lib', 'storage'])

_set = _get = () ->
  throw new Error("Not overriden -- no implementation found")

Storage = () ->
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

browserSetup = () ->
  _set = (key, value) ->
    keyString = JSON.stringify({key})
    valueString = JSON.stringify({value})
    localStorage.setItem(keyString, valueString)

  _get = (key) ->
    keyString = JSON.stringify({key})
    value = localStorage.getItem(keyString)
    if value?.length > 0
      return JSON.parse(value).value
    else
      return null

if !localStorage?
  # export for node.js
  nodeSetup()
else
  # export for browser
  browserSetup()

module.exports = Storage()
