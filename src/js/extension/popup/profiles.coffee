logger = require('../../lib/util/logging').logger(['ext', 'popup', 'profile'])

makeHeadingPanel = (service) ->
  headingPanel = $('<div class="panel-heading">')
  header = $('<h3 class="panel-title">').text(service)
  return headingPanel.append(header)

makeBodyPanel = (username) ->
  bodyPanel = $('<div class="panel-body">')

  accountDiv = $('<div class="col-xs-8 account-name">')
  account = $('<h4>').text(username)
  accountDiv.append(account)

  tokenDiv = $('<div class="col-xs-4 account-token">')
  tokenListGroup = $('<div class="list-group">')

  getTokenButton = $('<a href="#" class="list-group-item active">').text("Get token")
  tokenField = $('<div class="list-group-item">').text("123456")
  # TODO(predrag): Remove the 123456 text when the CSS is fixed to
  #                not resize the div as soon as text is added

  tokenListGroup.append(getTokenButton).append(tokenField)
  tokenDiv = tokenDiv.append tokenListGroup

  return bodyPanel.append(accountDiv).append(tokenDiv)

addProfile = (profile, {service, username}) ->
  mainProfileDiv = $('<div class="panel panel-default">')
  mainProfileDiv.append makeHeadingPanel(service)
  mainProfileDiv.append makeBodyPanel(username)

  $('#tab-profiles').append(mainProfileDiv)

handleProfiles = (profiles) ->
  if Object.keys(profiles).length == 0
    $('#profiles-empty').removeClass('hidden')
  else
    for own profile, data of profiles
      addProfile(profile, data)


Profiles =
  populate: (sender, password) ->
    sender.sendGetProfilesMessage password, (err, profiles) ->
      if err?
        logger("Unexpected error on sendGetProfiles", err)
        return
      else
        handleProfiles(profiles)


module.exports = Profiles
