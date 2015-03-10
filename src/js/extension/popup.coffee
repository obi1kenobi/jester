logging   = require('../lib/util/logging')
logger    = logging.logger(['ext', 'popup'])
constants = require('./constants')

SETUP_BUTTON_ID   = 'btn-setup'
GENCODE_BUTTON_ID = 'btn-gencode'
LOGIN_BUTTON_ID   = 'btn-login'

PROCEED_BUTTON_ID = 'btn-proceed'
BACK_BUTTON_ID    = 'btn-back'

USERNAME_INPUT_ID = 'inp-username'
PASSWORD_INPUT_ID = 'inp-pwd'

OPTIONS_TABLE_ID  = 'tbl-options'
INPUTS_TABLE_ID   = 'tbl-inputs'

INVISIBLE_DISPLAY = 'none'
VISIBLE_DISPLAY   = ''

INITIAL_STATE = 'initial'
LOGIN_STATE   = 'login'
SETUP_STATE   = 'setup'
GENCODE_STATE = 'gencode'

currentState = INITIAL_STATE

changeColor = (r, g, b) ->
  color = '#' + r.toString(16) + g.toString(16) + b.toString(16)
  logger("Setting login button color to #{color}")
  document.getElementById(LOGIN_BUTTON_ID).style.background = color

randomizeColor = () ->
  colors = (getRandomInt(0, 255) for i in [0..2])
  changeColor(colors...)

getRandomInt = (min, max) ->
  Math.floor(Math.random() * (max - min + 1)) + min;

resetUI = () ->
  currentState = INITIAL_STATE
  document.getElementById(OPTIONS_TABLE_ID).style.display = VISIBLE_DISPLAY
  document.getElementById(INPUTS_TABLE_ID).style.display = INVISIBLE_DISPLAY

advanceUI = (nextState) ->
  currentState = nextState
  document.getElementById(OPTIONS_TABLE_ID).style.display = INVISIBLE_DISPLAY
  document.getElementById(INPUTS_TABLE_ID).style.display = VISIBLE_DISPLAY
  document.getElementById(USERNAME_INPUT_ID).focus()

# window.onload fires every time the popup window is shown
window.onload = randomizeColor

initialize = () ->
  logger("Initializing...")
  attachEventListeners()
  resetUI()
  logger("All done.")

attachEventListeners = () ->
  document.getElementById(SETUP_BUTTON_ID).onclick = setupButtonClicked
  document.getElementById(GENCODE_BUTTON_ID).onclick = genCodeButtonClicked
  document.getElementById(LOGIN_BUTTON_ID).onclick = loginButtonClicked
  document.getElementById(PROCEED_BUTTON_ID).onclick = proceedButtonClicked
  document.getElementById(BACK_BUTTON_ID).onclick = backButtonClicked
  logger("Done setting up listeners...")

setupButtonClicked = () ->
  logger("Setup button clicked")
  advanceUI(SETUP_STATE)

genCodeButtonClicked = () ->
  logger("GenCode button clicked")
  advanceUI(GENCODE_STATE)

loginButtonClicked = () ->
  logger("Login button clicked")
  advanceUI(LOGIN_STATE)

proceedButtonClicked = () ->
  logger("Proceed button clicked")
  username = document.getElementById(USERNAME_INPUT_ID).value
  password = document.getElementById(PASSWORD_INPUT_ID).value
  type = ''
  switch currentState
    when SETUP_STATE
      type = constants.SETUP_MESSAGE
    when LOGIN_STATE
      type = constants.LOGIN_MESSAGE
    when GENCODE_STATE
      type = constants.GENCODE_MESSAGE
    else
      throw new Error("unsupported state on Proceed button click: #{currentState}")
  chrome.runtime.sendMessage {type, args: {username, password}}

backButtonClicked = () ->
  logger("Back button clicked")
  resetUI()


initialize()
