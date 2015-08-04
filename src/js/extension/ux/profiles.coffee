logger         = require('../../lib/util/logging').logger(['ext', 'ux', 'profiles'])
constants      = require('../../lib/config/constants')
sender         = require('../messaging/ui/sender')
unauthTimer    = require('./unauth_timer')

NO_TOKEN_TEXT = '<none>'

makeHeadingPanel = (service) ->
  headingPanel = $('<div class="panel-heading">')
  header = $('<h3 class="panel-title">').text(service)
  return headingPanel.append(header)

makeBodyPanel = (profile, storePassword, username) ->
  bodyPanel = $('<div class="panel-body">')

  accountDiv = $('<div class="col-xs-8 account-name">')
  account = $('<h4>').text(username)
  accountDiv.append(account)

  tokenDiv = $('<div class="col-xs-4 account-token">')
  tokenListGroup = $('<div class="list-group">')

  getTokenButton = $('<a href="#" class="list-group-item has-spinner active">') \
    .data('profile', profile) \
    .text("Get token")
    .append $('<i class="fa fa-spinner fa-spin">')
  tokenField = $('<div class="list-group-item">').text(NO_TOKEN_TEXT)
  getTokenButton.click(getTokenClickHandler(storePassword))

  tokenListGroup.append(getTokenButton).append(tokenField)
  tokenDiv = tokenDiv.append tokenListGroup

  return bodyPanel.append(accountDiv).append(tokenDiv)

getTokenClickHandler = (storePassword) ->
  return () ->
    unauthTimer.reset()
    buttonElement = $(this)
    profile = buttonElement.data('profile')
    buttonElement.addClass('spinner-active')
    sender.sendGetTokenMessage profile, storePassword, (err, token) ->
      buttonElement.removeClass('spinner-active')
      if err?
        logger("Unexpected error getting token:", err)
        return
      tokenTextElement = buttonElement.siblings('div')
      tokenTextElement.text(token)
      setTimeout () ->
        tokenTextElement.text(NO_TOKEN_TEXT)
      , constants.TEMPORARY_PASSWORD_VALIDITY_MS

addProfile = (profile, storePassword, {service, username}) ->
  mainProfileDiv = $('<div class="panel panel-default">')
  mainProfileDiv.append makeHeadingPanel(service)
  mainProfileDiv.append makeBodyPanel(profile, storePassword, username)

  $('#tab-profiles').append(mainProfileDiv)

handleProfiles = (storePassword, profiles) ->
  if Object.keys(profiles).length == 0
    $('#profiles-empty').removeClass('hidden')
  else
    for own profile, data of profiles
      addProfile(profile, storePassword, data)


Profiles =
  populate: (storePassword) ->
    sender.sendGetProfilesMessage storePassword, (err, profiles) ->
      if err?
        logger("Unexpected error on sendGetProfiles", err)
        return
      else
        handleProfiles(storePassword, profiles)


module.exports = Profiles
