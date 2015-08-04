logger = require('../util/logging').logger(['lib', 'sstore', 'storage'])
random = require('../crypto/secure_random')

PROFILES_KEY = "profiles"
CONFIG_KEY = "config"
SALT_KEY = "salt"

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
  getSalt: () ->
    salt = get(SALT_KEY)
    if !salt?
      salt = random.getRandomSalt()
      set(SALT_KEY, salt)
    return salt

  getProfileNames: () ->
    profiles = get(PROFILES_KEY)
    if profiles?
      return Object.keys(profiles)
    else
      return []

  getProfile: (profile) ->
    return get(PROFILES_KEY)?[profile]

  setProfile: (profile, iv, authTag, publicData, ciphertext) ->
    profiles = get(PROFILES_KEY)
    if !profiles?
      profiles = {}
    profiles[profile] = {iv, authTag, publicData, ciphertext}
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

  setConfig: (iv, authTag, ciphertext) ->
    return set(CONFIG_KEY, {iv, authTag, ciphertext})


module.exports = Storage
