expect                  = require('chai').expect
passwords               = require('../lib/passwords')
constants               = require('../lib/config/constants')

describe 'Password generation and encryption', () ->
  describe 'Password generation', () ->
    funcGen = (size) ->
      return () -> passwords.generateRandomPassword(size)

    it 'should not allow passwords with fewer than 8 bytes of entropy', () ->
      expect(funcGen(-1)).to.throw(Error, /Password length cannot be less than 8 bytes/)
      expect(funcGen(0)).to.throw(Error, /Password length cannot be less than 8 bytes/)
      expect(funcGen(1)).to.throw(Error, /Password length cannot be less than 8 bytes/)
      expect(funcGen(constants.MIN_PASSWORD_BYTES - 1)).to.throw( \
        Error, /Password length cannot be less than 8 bytes/)
      expect(funcGen("abc")).to.throw(Error)

    it 'should generate random passwords of the correct length', () ->
      # 3 bytes = 4 chars in base64
      min_bytes = constants.MIN_PASSWORD_BYTES
      for length in [min_bytes..min_bytes+3]
        expectedBase64Length = Math.round((length + 1) / 3) * 4
        expect(passwords.generateRandomPassword(length)).to.have.length(expectedBase64Length)
