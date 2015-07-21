expect    = require('chai').expect
logger    = require('../src/js/lib/util/logging').logger(['test', 'logging'])

describe 'Make sure Mocha and logging is set up correctly', () ->
  it 'should log and succeed', () ->
    logger("this is a test of the logging system")
