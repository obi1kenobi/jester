logger = require('../util/logging').logger(['lib', 'sstore', 'storage'])

PROFILES_KEY = "profiles"
CONFIG_KEY = "config"

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

  setProfile: (profile, salt, iv, authTag, publicData, ciphertext) ->
    profiles = get(PROFILES_KEY)
    if !profiles?
      profiles = {}
    profiles[profile] = {salt, iv, authTag, publicData, ciphertext}
    set(PROFILES_KEY, profiles)

  removeProfile: (profile) ->
    profiles = get(PROFILES_KEY)
    if !profiles?
      profiles = {}
    if profiles[profile]?
      delete profiles[profile]
    set(PROFILES_KEY, profiles)

  getConfig: () ->
    return get(CONFIG_KEY)

  setConfig: (salt, iv, authTag, ciphertext) ->
    return set(CONFIG_KEY, {salt, iv, authTag, ciphertext})


module.exports = Storage
