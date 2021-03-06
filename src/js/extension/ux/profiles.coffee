logger             = require('../../lib/util/logging').logger(['ext', 'ux', 'profiles'])
constants          = require('../../lib/config/constants')
sender             = require('../messaging/ui/sender')
unauthTimer        = require('./tools/unauth_timer')
ephemeralStorage   = require('./tools/ephemeral_storage')
NotificationBar    = require('./tools/notification_bar')

NO_TOKEN_TEXT = '<none>'
INACTIVE_PROFILE_TEXT = 'Profile inactive!'
notification = new NotificationBar($('#alert-profiles'))

makeHeadingPanel = (service) ->
  headingPanel = $('<div class="panel-heading">')
  header = $('<strong class="panel-title">').text(service)
  # remove = $('<i class="fa fa-times panel-remove">')
  return headingPanel.append(header) #.append(remove)

makeBodyPanel = (profile, username, valid) ->
  bodyPanel = $('<div class="panel-body">')

  accountDiv = $('<div class="col-xs-8 account-name">')
  account = $('<h4>').text(username)
  accountDiv.append(account)

  tokenDiv = $('<div class="col-xs-4 account-token">')
  tokenListGroup = $('<div class="list-group">')

  getTokenButton = $('<a href="#" class="list-group-item has-spinner active">') \
    .data('profile', profile)
    .data('valid', valid)
    .append $('<i class="fa fa-spinner fa-spin">')
  tokenField = $('<div class="list-group-item">')

  getTokenButton.click(tokenClickHandler)
  tokenListGroup.append(getTokenButton).append(tokenField)
  tokenDiv = tokenDiv.append(tokenListGroup)

  bodyPanel.append(accountDiv).append(tokenDiv)

  updateProfileAppearance(getTokenButton)

  return bodyPanel

updateProfileAppearance = (buttonElement) ->
  if buttonElement.data('valid')
    # setup the panel
    buttonElement.parents('.panel').removeClass('panel-danger')
      .addClass('panel-default')

    # setup the button
    buttonElement.removeClass('has-error')
      .text('Get token')

    # setup the text box
    buttonElement.siblings('div.list-group-item').removeClass('disabled')
      .text(NO_TOKEN_TEXT)
  else
    # setup the panel
    buttonElement.parents('.panel').removeClass('panel-default')
      .addClass('panel-danger')

    # setup the button
    buttonElement.addClass('has-error')
      .text('Repair')

    # setup the text box
    buttonElement.siblings('div.list-group-item').addClass('disabled')
      .text(INACTIVE_PROFILE_TEXT)


handleGetToken = (buttonElement) ->
  {storePassword} = ephemeralStorage
  profile = buttonElement.data('profile')

  message = "Creating your token..."
  notification.display('Please wait', message, 60000, 'info')

  sender.sendGetTokenMessage profile, storePassword, (err, token) ->
    buttonElement.removeClass('spinner-active')

    if err?
      logger("Unexpected error getting token:", err)
      buttonElement.data('valid', false)
      updateProfileAppearance(buttonElement)

      buttonElement.click(tokenClickHandler)

      message = "Unexpected error, couldn't get token. This profile is now disabled."
      notification.display('Error!', message, 60000, 'danger')
      return

    tokenTextElement = buttonElement.siblings('div')
    tokenTextElement.text(token)
    message = "Token created successfully."
    notification.display('Success!', message, 30000, 'success')

    setTimeout () ->
      message = "Your token expired and is no longer valid."
      notification.display('Token expired!', message, 20000, 'info')
      tokenTextElement.text(NO_TOKEN_TEXT)
      buttonElement.click(tokenClickHandler)
    , constants.TEMPORARY_PASSWORD_VALIDITY_MS

handleRepair = (buttonElement) ->
  {storePassword} = ephemeralStorage
  profile = buttonElement.data('profile')

  message = "Attempting to repair the profile..."
  notification.display('Please wait', message, 60000, 'info')

  sender.sendRepairProfileMessage profile, storePassword, (err, valid) ->
    buttonElement.removeClass('spinner-active')

    if err?
      logger("Repair encountered an error:", err)

    if err? or !valid
      message = "Please try again later or reset your password manually."
      notification.display('Repair failed!', message, 60000, 'danger')
    else
      buttonElement.data('valid', true)
      updateProfileAppearance(buttonElement)

      message = "The repair was successful, the profile is re-enabled."
      notification.display('Success!', message, 30000, 'success')

    buttonElement.click(tokenClickHandler)

tokenClickHandler = () ->
  unauthTimer.reset()
  buttonElement = $(this)
  buttonElement.off('click', tokenClickHandler)

  valid = buttonElement.data('valid')
  buttonElement.addClass('spinner-active')

  if valid
    handleGetToken(buttonElement)
  else
    handleRepair(buttonElement)

addProfile = (profile, {service, username, valid}) ->
  $('#profiles-empty').addClass('hidden')

  logger("Adding panel for profile #{profile}")
  mainProfileDiv = $('<div class="panel">')
  if valid
    mainProfileDiv.addClass('panel-default')
  else
    mainProfileDiv.addClass('panel-danger')

  mainProfileDiv.append makeHeadingPanel(service)
  mainProfileDiv.append makeBodyPanel(profile, username, valid)

  $('#tab-profiles').append(mainProfileDiv)

handleProfiles = (profiles) ->
  if Object.keys(profiles).length == 0
    $('#profiles-empty').removeClass('hidden')
  else
    for own profile, data of profiles
      addProfile(profile, data)


Profiles =
  setup: (cb) ->
    {storePassword} = ephemeralStorage
    sender.sendGetProfilesMessage storePassword, (err, profiles) ->
      if err?
        logger("Unexpected error on sendGetProfiles", err)
        cb("Unexpected error on sendGetProfiles: #{err}")
        return
      else
        handleProfiles(profiles)
        cb()

  addProfile: addProfile


module.exports = Profiles
