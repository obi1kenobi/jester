expect      = require('chai').expect
storage     = require('../../src/js/lib/secure_store/storage')
stringUtils = require('../../src/js/lib/util/string')

getRandomBase64 = () ->
  array = new Uint8Array(16)
  window.crypto.getRandomValues(array)
  return stringUtils.arrayToBase64(array)

describe 'Secure store, profile storage', () ->
  it 'remembers profiles', () ->
    expect(storage.getProfileNames()).to.eql([])

    profileName = "test_profile"
    profileData =
      salt: "test_salt"
      iv: getRandomBase64()
      authTag: getRandomBase64()
      ciphertext: "test_ciphertext"

    storage.setProfile(profileName, profileData.salt, profileData.iv, \
                       profileData.authTag, profileData.ciphertext)

    expect(storage.getProfile(profileName)).to.eql(profileData)
    expect(storage.getProfileNames()).to.eql([profileName])

    storage.removeProfile(profileName)
    expect(storage.getProfileNames()).to.eql([])
    expect(storage.getProfile(profileName)).to.not.exist
