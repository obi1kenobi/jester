logging   = require('../lib/util/logging')
logger    = logging.logger(["ext", "core"])
constants = require('./constants')
shim      = require('./shim')

yahooInfo = require('../lib/config/domain').yahoo

messageHandlers = {}

initialize = () ->
  logger("Initializing...")
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
  elementValues = {}
  elementValues[yahooInfo.login.args.usernameId] = username
  elementValues[yahooInfo.login.args.passwordId] = password
  submitElementId = yahooInfo.login.args.submitId
  shim yahooInfo.login.url, elementValues, submitElementId, () ->
    logger("Universal content script finished executing")

setupMessageHandler = (args) ->
  logger('Setup message handler not implemented yet')

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
          crypto.decryptString ciphertext, key, iv, authTag, (err, plaintext) ->
            if err?
              logger("Error when decrypting!")
              throw err
            else
              logger("Decrypted text: #{plaintext}")

initialize()
testCrypto()
