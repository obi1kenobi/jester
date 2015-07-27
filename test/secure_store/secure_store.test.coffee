expect       = require('chai').expect
secureStore  = require('../../src/js/lib/secure_store')

describe 'Secure store', () ->
  beforeEach () ->
    localStorage.clear()

  it 'stores and retrieves profiles', (done) ->
    password = "test_password123"
    profile = "test_secure_store_profile1"
    publicData =
      a: 123
      b: "456"

    secretData =
      xyz: "abc"
      t: 0

    expect(secureStore.getProfileNames()).to.eql([])

    secureStore.setProfile profile, password, publicData, secretData, (err, res) ->
      expect(err).to.not.exist

      expect(secureStore.getPublic(profile)).to.eql(publicData)

      secureStore.getSecret profile, password, (err, res) ->
        expect(err).to.not.exist
        expect(res).to.eql(secretData)
        done()

  it 'refuses to decrypt profiles with incorrect password', (done) ->
    password = "test_password123"
    profile = "test_secure_store_profile2"
    publicData =
      a: 123
      b: "456"

    secretData =
      xyz: "abc"
      t: 0

    secureStore.setProfile profile, password, publicData, secretData, (err, res) ->
      expect(err).to.not.exist

      secureStore.getSecret profile, password + "456", (err, res) ->
        expect(err).to.exist
        expect(res).to.not.exist
        done()

  it 'stores and retrieves config', (done) ->
    password = "test_password123"
    config =
      abc: 12
      de: "1234"

    expect(secureStore.configExists()).to.eql(false)

    secureStore.setConfig password, config, (err) ->
      expect(err).to.not.exist

      expect(secureStore.configExists()).to.eql(true)

      secureStore.getConfig password, (err, res) ->
        expect(err).to.not.exist
        expect(res).to.eql(config)
        done()

  it 'refuses to decrypt config with incorrect password', (done) ->
    password = "test_password123"
    config =
      ab: 123
      def: "124"

    secureStore.setConfig password, config, (err) ->
      expect(err).to.not.exist

      secureStore.getConfig password + "1", (err, res) ->
        expect(err).to.exist
        expect(res).to.not.exist
        done()
