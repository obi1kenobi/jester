logger          = require('../../lib/util/logging').logger(['ext', 'ux', 'index'])
constants       = require('../../lib/config/constants')
sender          = require('../messaging/ui/sender')
popupAuth       = require('./auth')
popupProfiles   = require('./profiles')
popupAddNew     = require('./addnew')

currentTabId = null
unauthTimer = null

main = () ->
  setupAutoUnauth()
  popupAuth.setup sender, (err, password) ->
    if err?
      logger("Unexpected error returned from auth setup", err)
      return
    else
      setupTabs()
      popupProfiles.populate(sender, password, resetUnauthTimer)
      popupAddNew.setup(sender, password, resetUnauthTimer)

setupTabs = () ->
  deselectAddNewSelectors = () ->
    $('#addnew-selector').children().removeClass('active')
    $('#addnew-creds').addClass('hidden')

  $('#tabhead-home').click () ->
    resetUnauthTimer()
    $(this).siblings().removeClass('active')
    $(this).addClass('active')
    $(this).parent().siblings('.tab').addClass('hidden')

    $('#tab-profiles').removeClass('hidden')
    deselectAddNewSelectors()

  $('#tabhead-addnew').click () ->
    resetUnauthTimer()
    $(this).siblings().removeClass('active')
    $(this).addClass('active')
    $(this).parent().siblings('.tab').addClass('hidden')

    $('#tab-addnew').removeClass('hidden')

  $('#tabhead-about').click () ->
    resetUnauthTimer()
    $(this).siblings().removeClass('active')
    $(this).addClass('active')
    $(this).parent().siblings('.tab').addClass('hidden')

    $('#tab-about').removeClass('hidden')
    deselectAddNewSelectors()

closeTab = () ->
  if !currentTabId?
    logger("Unexpectedly did not have a current tab id to close.")
    return

  chrome.tabs.remove(currentTabId)

setupAutoUnauth = () ->
  chrome.tabs.getCurrent (tab) ->
    currentTabId = tab.id

    if !currentTabId?
      logger("Unexpectedly couldn't get ID of the current tab.")
      return

    unauthTimer = setTimeout(closeTab, (constants.AUTO_UNAUTH_SECONDS * 1000))

resetUnauthTimer = () ->
  logger("Resetting unauth timer...")
  clearTimeout(unauthTimer)
  unauthTimer = setTimeout(closeTab, (constants.AUTO_UNAUTH_SECONDS * 1000))

$(document).ready(main)
