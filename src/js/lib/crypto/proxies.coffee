Proxies =
  ###
  Generate and return 'count' cryptographically-secure random bytes.
  ###
  getSecureRandomBytes: (count) ->
    throw new Error("Not overriden -- no implementation found")

nodeSetup = () ->
  crypto = require('crypto')
  Proxies.getSecureRandomBytes = (count) ->
    return crypto.randomBytes(count)

browserSetup = () ->
  Proxies.getSecureRandomBytes = (count) ->
    arr = new Uint8Array(count)
    window.crypto.getRandomValues(arr)
    return arr


if !window?
  # we're in Node
  nodeSetup()
else
  # running in browser
  browserSetup()

module.exports = Proxies
