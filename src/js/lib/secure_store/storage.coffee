logger = require('../util/logging').logger(['lib', 'sstore', 'storage'])

PROFILES_KEY = "profiles"

get = (key) ->
  keyString = JSON.stringify({key})
  val = localStorage.getItem(keyString)
  if val?.length > 0
    return JSON.parse(val).val
  else
    return null

set = (key, val) ->
  keyString = JSON.stringify({key})
  valString = JSON.stringify({val})
  localStorage.setItem(keyString, valString)


Storage =
  getProfileNames: () ->
    profiles = get(PROFILES_KEY)
    if profiles?
      return Object.keys(profiles)
    else
      return []

  getProfile: (profile) ->
    return get(PROFILES_KEY)?[profile]

  setProfile: (profile, salt, iv, authTag, ciphertext) ->
    profiles = get(PROFILES_KEY)
    profiles[profile] = {salt, iv, authTag, ciphertext}
    set(PROFILES_KEY, profiles)


module.exports = Storage
