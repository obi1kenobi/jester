logger                = require('../../lib/util/logging').logger(['ext', 'ux', 'index'])
constants             = require('../../lib/config/constants')
sender                = require('../messaging/ui/sender')
unauthTimer           = require('./tools/unauth_timer')
ephemeralStorage      = require('./tools/ephemeral_storage')
popupAuth             = require('./auth')
popupProfiles         = require('./profiles')
popupAddNew           = require('./addnew')

main = () ->
  setupAutoUnauth()
  popupAuth.setup (err, password) ->
    ephemeralStorage.storePassword = password
    if err?
      logger("Unexpected error returned from auth setup", err)
      return

    $('#jester-loading').removeClass('hidden')
    setupTabs()
    popupAddNew.setup()
    popupProfiles.setup (err, res) ->
      if err?
        logger("Unexpected error returned from profile setup", err)
        return

      $('#jester-loading').addClass('hidden')
      $('#jester-authed').removeClass('hidden')

setupTabs = () ->
  deselectAddNewSelectors = () ->
    $('#addnew-selector').children().removeClass('active')
    $('#addnew-creds').addClass('hidden')

  $('#tabhead-home').click () ->
    unauthTimer.reset()
    $(this).siblings().removeClass('active')
    $(this).addClass('active')
    $(this).parent().siblings('.tab').addClass('hidden')

    $('#tab-profiles').removeClass('hidden')
    deselectAddNewSelectors()

  $('#tabhead-addnew').click () ->
    unauthTimer.reset()
    $(this).siblings().removeClass('active')
    $(this).addClass('active')
    $(this).parent().siblings('.tab').addClass('hidden')

    $('#tab-addnew').removeClass('hidden')

  $('#tabhead-about').click () ->
    unauthTimer.reset()
    $(this).siblings().removeClass('active')
    $(this).addClass('active')
    $(this).parent().siblings('.tab').addClass('hidden')

    $('#tab-about').removeClass('hidden')
    deselectAddNewSelectors()

setupAutoUnauth = () ->
  chrome.tabs.getCurrent (tab) ->
    if !tab.id?
      logger("Unexpectedly got tab with no id")
      return
    unauthTimer.setup(tab.id)

$(document).ready(main)
