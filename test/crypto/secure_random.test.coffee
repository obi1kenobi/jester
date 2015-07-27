expect       = require('chai').expect
constants    = require('../../src/js/lib/config/constants')
secureRandom = require('../../src/js/lib/crypto/secure_random')

describe 'Secure random', () ->
  it 'should return random passwords of correct length', () ->
    minBytes = constants.MIN_PASSWORD_BYTES

    lengths = [minBytes, minBytes + 3, 2 * minBytes]

    for l in lengths
      password = secureRandom.getRandomPassword(l)
      expect(password).to.have.length.at.least(l)

  it 'should throw instead of generating short password', () ->
    minBytes = constants.MIN_PASSWORD_BYTES
    throwFn = () ->
      return secureRandom.getRandomPassword(minBytes - 1)

    expect(throwFn).to.throw(Error, /Password length cannot be less than/)

  it 'should return random salts of the correct number of bytes', () ->
    expect(secureRandom.getRandomSalt()).to.have.length(constants.SALT_BYTES)

  it 'should return random numeric codes of correct length', () ->
    digits = 6
    numTests = 10
    for i in [0...numTests]
      code = secureRandom.getRandomNumericCode(digits)
      expect(code).to.have.length(digits)
