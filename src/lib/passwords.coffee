Passwords =
  ###
  Creates a new securely randomly-generated password, and returns it
  encoded in base64.
  ###
  generateRandomPassword: () ->
    length = 32
    arr = new Uint8Array(length)
    window.crypto.getRandomValues(arr)

    # convert bytes to string, and convert to base64
    str = String.fromCharCode.apply(null, arr)
    return btoa(str)

  decryptPassword: (encrypted) ->
    throw new Error("Not implemented")

  encryptPassword: (password) ->
    throw new Error("Not implemented")

if module?.exports?
  # export for node.js
  module.exports = Passwords
else
  # export for browser
  this.jester.passwords = Passwords
