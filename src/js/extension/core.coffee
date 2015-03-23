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

  # Workaround because Chrome does not currently support any key-derivation function
  promise = window.crypto.subtle.generateKey {name: 'AES-GCM', length: 256}, \
                                             false, \
                                             ["encrypt", "decrypt"]
  promise.catch (err) ->
    logger("Failed to generate AES-GCM key")
    throw err

  # crypto.getOrCreateEncryptionKey password, salt, (err, key) ->
  #   if err?
  #     logger("Error when making encryption key: #{JSON.stringify(err)}")
  #     throw err
  #   else
  promise.then (key) ->
    crypto.encryptString plaintext, key, (err, result) ->
      if err?
        logger("Error when encrypting: #{JSON.stringify(err)}")
        throw err
      else
        {iv, authTag, ciphertext} = result
        # optionally, corrupt authTag to see if decryption fails
        # authTag[0] += 1
        crypto.decryptString ciphertext, key, iv, authTag, (err, plaintext) ->
          if err?
            logger("Error when decrypting: #{JSON.stringify(err)}")
            throw err
          else
            logger("Decrypted text: #{plaintext}")

initialize()
testCrypto()
