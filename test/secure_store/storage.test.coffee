expect      = require('chai').expect
storage     = require('../../src/js/lib/secure_store/storage')
stringUtils = require('../../src/js/lib/util/string')

getRandomBase64 = () ->
  array = new Uint8Array(16)
  window.crypto.getRandomValues(array)
  return stringUtils.arrayToBase64(array)

describe 'Secure store, profile storage', () ->
  beforeEach () ->
    localStorage.clear()

  it 'remembers profiles', () ->
    expect(storage.getProfileNames()).to.eql([])

    profileName = "test_profile"
    profileData =
      salt: "test_salt"
      iv: getRandomBase64()
      authTag: getRandomBase64()
      publicData:
        abc: 1234
        de: "fgh"
      ciphertext: "test_ciphertext"

    storage.setProfile(profileName, profileData.salt, profileData.iv, \
                       profileData.authTag, profileData.publicData, \
                       profileData.ciphertext)

    expect(storage.getProfile(profileName)).to.eql(profileData)
    expect(storage.getProfileNames()).to.eql([profileName])

    storage.removeProfile(profileName)
    expect(storage.getProfileNames()).to.eql([])
    expect(storage.getProfile(profileName)).to.not.exist

  it 'remembers config data', () ->
    expect(storage.getConfig()).to.not.exist

    config =
      salt: "test_salt"
      iv: getRandomBase64()
      authTag: getRandomBase64()
      ciphertext: "test_ciphertext"

    storage.setConfig(config.salt, config.iv, \
                      config.authTag, config.ciphertext)

    expect(storage.getConfig()).to.eql(config)
