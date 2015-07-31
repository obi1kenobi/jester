logger    = require('../../lib/util/logging').logger(['ext', 'popup', 'profile'])
constants = require('../../lib/config/constants')

NO_TOKEN_TEXT = '<none>'

makeHeadingPanel = (service) ->
  headingPanel = $('<div class="panel-heading">')
  header = $('<h3 class="panel-title">').text(service)
  return headingPanel.append(header)

makeBodyPanel = (profile, sender, storePassword, username) ->
  bodyPanel = $('<div class="panel-body">')

  accountDiv = $('<div class="col-xs-8 account-name">')
  account = $('<h4>').text(username)
  accountDiv.append(account)

  tokenDiv = $('<div class="col-xs-4 account-token">')
  tokenListGroup = $('<div class="list-group">')

  getTokenButton = $('<a href="#" class="list-group-item active">') \
    .data('profile', profile) \
    .text("Get token")
  tokenField = $('<div class="list-group-item">').text(NO_TOKEN_TEXT)
  getTokenButton.click(getTokenClickHandler(sender, storePassword))

  tokenListGroup.append(getTokenButton).append(tokenField)
  tokenDiv = tokenDiv.append tokenListGroup

  return bodyPanel.append(accountDiv).append(tokenDiv)

getTokenClickHandler = (sender, storePassword) ->
  return () ->
    buttonElement = $(this)
    profile = buttonElement.data('profile')
    logger("Clicked get-token for profile #{profile}")
    sender.sendGetTokenMessage profile, storePassword, (err, token) ->
      if err?
        logger("Unexpected error getting token:", err)
        return
      tokenTextElement = buttonElement.siblings('div')
      tokenTextElement.text(token)
      setTimeout () ->
        tokenTextElement.text(NO_TOKEN_TEXT)
      , constants.TEMPORARY_PASSWORD_VALIDITY_MS

addProfile = (profile, sender, storePassword, {service, username}) ->
  mainProfileDiv = $('<div class="panel panel-default">')
  mainProfileDiv.append makeHeadingPanel(service)
  mainProfileDiv.append makeBodyPanel(profile, sender, storePassword, username)

  $('#tab-profiles').append(mainProfileDiv)

handleProfiles = (sender, storePassword, profiles) ->
  if Object.keys(profiles).length == 0
    $('#profiles-empty').removeClass('hidden')
  else
    for own profile, data of profiles
      addProfile(profile, sender, storePassword, data)


Profiles =
  populate: (sender, storePassword) ->
    sender.sendGetProfilesMessage storePassword, (err, profiles) ->
      if err?
        logger("Unexpected error on sendGetProfiles", err)
        return
      else
        handleProfiles(sender, storePassword, profiles)


module.exports = Profiles
