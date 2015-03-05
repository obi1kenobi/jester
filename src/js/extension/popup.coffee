SETUP_BUTTON_ID = "btn-setup"
GENCODE_BUTTON_ID = "btn-gencode"
LOGIN_BUTTON_ID = "btn-login"

logging = require('../lib/util/logging')
logger = logging.logger(['ext', 'popup'])

changeColor = (r, g, b) ->
  color = '#' + r.toString(16) + g.toString(16) + b.toString(16)
  logger("Setting login button color to #{color}")
  document.getElementById(LOGIN_BUTTON_ID).style.background = color

randomizeColor = () ->
  colors = (getRandomInt(0, 255) for i in [0..2])
  changeColor(colors...)

getRandomInt = (min, max) ->
  Math.floor(Math.random() * (max - min + 1)) + min;

# window.onload fires every time the popup window is shown
window.onload = randomizeColor

initialize = () ->
  logger("Initializing...")
  attachEventListeners()
  logger("All done.")

attachEventListeners = () ->
  document.getElementById(SETUP_BUTTON_ID).onclick = setupButtonClicked
  document.getElementById(GENCODE_BUTTON_ID).onclick = genCodeButtonClicked
  document.getElementById(LOGIN_BUTTON_ID).onclick = loginButtonClicked
  logger("Done setting up listeners...")

setupButtonClicked = () ->
  logger("Setup button clicked")

genCodeButtonClicked = () ->
  logger("GenCode button clicked")

loginButtonClicked = () ->
  logger("Login button clicked")
  chrome.runtime.sendMessage("Login")

initialize()
