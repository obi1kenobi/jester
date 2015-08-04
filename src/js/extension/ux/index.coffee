logger          = require('../../lib/util/logging').logger(['ext', 'ux', 'index'])
constants       = require('../../lib/config/constants')
sender          = require('../messaging/ui/sender')
popupAuth       = require('./auth')
popupProfiles   = require('./profiles')
popupAddNew     = require('./addnew')
unauthTimer     = require('./unauth_timer')

main = () ->
  setupAutoUnauth()
  popupAuth.setup (err, password) ->
    if err?
      logger("Unexpected error returned from auth setup", err)
      return
    else
      setupTabs()
      popupProfiles.populate(password)
      popupAddNew.setup(password)

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
