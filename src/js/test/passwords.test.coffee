expect                  = require('chai').expect
passwords               = require('../lib/passwords')

describe 'Password generation and encryption', () ->
  describe 'Password generation', () ->
    funcGen = (size) ->
      return () -> passwords.generateRandomPassword(size)

    it 'should not allow passwords with fewer than 8 bytes of entropy', () ->
      expect(funcGen(-1)).to.throw(Error, /Password length cannot be less than 8 bytes/)
      expect(funcGen(0)).to.throw(Error, /Password length cannot be less than 8 bytes/)
      expect(funcGen(1)).to.throw(Error, /Password length cannot be less than 8 bytes/)
      expect(funcGen(7)).to.throw(Error, /Password length cannot be less than 8 bytes/)
      expect(funcGen("abc")).to.throw(Error)

    it 'should generate random passwords of the correct length', () ->
      # 3 bytes = 4 chars in base64
      for length in [8..11]
        expectedBase64Length = Math.round((length + 1) / 3) * 4
        expect(passwords.generateRandomPassword(length)).to.have.length(expectedBase64Length)
