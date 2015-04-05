logging   = require('../lib/util/logging')
logger    = logging.logger(["ext", "core"])
constants = require('./constants')
shim      = require('./shim')
jester    = require('../lib/index')

SERVICE_NAME = 'yahoo'
yahooInfo = require('../lib/config/service').getInfo(SERVICE_NAME)

messageHandlers = {}

initialize = () ->
  logger("Initializing...")
  jester.registerShim shim
  messageHandlers[constants.LOGIN_MESSAGE] = loginMessageHandler
  messageHandlers[constants.SETUP_MESSAGE] = setupMessageHandler
  messageHandlers[constants.GENCODE_MESSAGE] = genCodeMessageHandler
  chrome.runtime.onMessage.addListener messageListener

messageListener = (message, sender, response) ->
  logger("Received message: #{JSON.stringify(message)}")

  {type, args} = message
  if !messageHandlers[type]?
    throw new Error("Unexpected message type #{type} with args #{JSON.stringify(args)}")

  messageHandlers[type](args)

loginMessageHandler = (args) ->
  {username, password} = args
  jester.login SERVICE_NAME, username, password, (err, res) ->
    if err?
      logger("Login failed:", err)
    else
      logger("Login successful!")

setupMessageHandler = (args) ->
  {username, password} = args
  jester.initNewService SERVICE_NAME, username, password, (err, res) ->
    if err?
      logger("Setup failed:", err)
    else
      logger("Setup successful!")

genCodeMessageHandler = (args) ->
  logger('GenCode message handler not implemented yet')

testCrypto = () ->
  crypto = require('../lib/crypto/proxies')
  password = "predrag123"
  plaintext = "Hello world!"
  salt = "salt and pepper"

  crypto.getOrCreateEncryptionKey password, salt, (err, key) ->
    if err?
      logger("Failed to derive key from password!")
      throw err
    else
      crypto.encryptString plaintext, key, (err, result) ->
        if err?
          logger("Error when encrypting!")
          throw err
        else
          {iv, authTag, ciphertext} = result
          # optionally, corrupt authTag to see if decryption fails
          # authTag[0] += 1
          crypto.decryptString ciphertext, key, iv, authTag, (err, plaintext2) ->
            if err?
              logger("Error when decrypting!")
              throw err
            else
              if plaintext == plaintext2
                logger("Decryption test success!")
              else
                logger("Decryption mismatch: #{plaintext} != #{plaintext2}")

testPasswordStorage = () ->
  passwords = require('../lib/passwords')

  serviceName  = "service123"
  userPassword = "predrag123"

  passwords.setRandomPassword serviceName, userPassword, (err, randomPassword) ->
    if err?
      logger("Error setting random password!")
      throw err
    else
      passwords.getPassword serviceName, userPassword, (err, password) ->
        if err?
          logger("Error getting password!")
          throw err
        else
          if randomPassword != password
            logger("Password mismatch: #{randomPassword} != #{password}")
          else
            logger("Password test success!")


initialize()
testCrypto()
testPasswordStorage()
