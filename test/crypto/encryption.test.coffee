expect      = require('chai').expect
crypto      = require('../../src/js/lib/crypto/encryption')
stringUtils = require('../../src/js/lib/util/string')

describe 'Crypto', () ->
  it 'encrypts and decrypts correctly', (done) ->
    plaintext = "this is the plaintext data"
    password = "my very secret password"
    salt = "gotta add salt"

    crypto.encryptString plaintext, password, salt, (err, res) ->
      expect(err).to.not.exist
      expect(res).to.exist

      {iv, authTag, ciphertext} = res
      expect(iv).to.exist
      expect(authTag).to.exist
      expect(ciphertext).to.exist

      crypto.decryptString ciphertext, password, \
                           salt, iv, authTag, (err, plaintext2) ->
        expect(err).to.not.exist
        expect(plaintext).to.eql(plaintext2)
        done()

  it 'refuses to decrypt with incorrect password', (done) ->
    plaintext = "this is the plaintext data"
    password = "my very secret password"
    brokenPassword = "wrong password"
    salt = "gotta add salt"

    crypto.encryptString plaintext, password, salt, (err, res) ->
      expect(err).to.not.exist
      expect(res).to.exist

      {iv, authTag, ciphertext} = res
      expect(iv).to.exist
      expect(authTag).to.exist
      expect(ciphertext).to.exist

      crypto.decryptString ciphertext, brokenPassword, \
                           salt, iv, authTag, (err, plaintext2) ->
        expect(err).to.exist
        expect(plaintext2).to.not.exist
        done()

  it 'refuses to decrypt with incorrect salt', (done) ->
    plaintext = "this is the plaintext data"
    password = "my very secret password"
    salt = "gotta add salt"
    brokenSalt = "wrong salt"

    crypto.encryptString plaintext, password, salt, (err, res) ->
      expect(err).to.not.exist
      expect(res).to.exist

      {iv, authTag, ciphertext} = res
      expect(iv).to.exist
      expect(authTag).to.exist
      expect(ciphertext).to.exist

      crypto.decryptString ciphertext, password, \
                           brokenSalt, iv, authTag, (err, plaintext2) ->
        expect(err).to.exist
        expect(plaintext2).to.not.exist
        done()

  it 'refuses to decrypt with incorrect authTag', (done) ->
    plaintext = "this is the plaintext data"
    password = "my very secret password"
    salt = "gotta add salt"

    crypto.encryptString plaintext, password, salt, (err, res) ->
      expect(err).to.not.exist
      expect(res).to.exist

      {iv, authTag, ciphertext} = res
      expect(iv).to.exist
      expect(authTag).to.exist
      expect(ciphertext).to.exist

      authTagArr = stringUtils.base64ToUint8Array(authTag)
      if authTagArr[0] == 0
        authTagArr[0] = 1
      else
        authTagArr[0] -= 1
      authTag = stringUtils.arrayToBase64(authTagArr)

      crypto.decryptString ciphertext, password, \
                           salt, iv, authTag, (err, plaintext2) ->
        expect(err).to.exist
        expect(plaintext2).to.not.exist
        done()
