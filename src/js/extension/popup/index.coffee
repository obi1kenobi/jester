logger          = require('../../lib/util/logging').logger(['ext', 'popup_main'])
sender          = require('../messaging/ui/sender')
popupAuth       = require('./auth')
popupProfiles   = require('./profiles')
popupAddNew     = require('./addnew')

main = () ->
  setupTabs()
  popupAuth.setup sender, (err, password) ->
    if err?
      logger("Unexpected error returned from setupAuth", err)
      return
    else
      popupProfiles.populate(sender, password)
      popupAddNew.setup(sender, password)

setupTabs = () ->
  deselectAddNewSelectors = () ->
    $('#addnew-selector').children().removeClass('active')
    $('#addnew-creds').addClass('hidden')

  $('#tabhead-home').click () ->
    $(this).siblings().removeClass('active')
    $(this).addClass('active')
    $(this).parent().siblings('.tab').addClass('hidden')

    $('#tab-profiles').removeClass('hidden')
    deselectAddNewSelectors()

  $('#tabhead-addnew').click () ->
    $(this).siblings().removeClass('active')
    $(this).addClass('active')
    $(this).parent().siblings('.tab').addClass('hidden')

    $('#tab-addnew').removeClass('hidden')

  $('#tabhead-about').click () ->
    $(this).siblings().removeClass('active')
    $(this).addClass('active')
    $(this).parent().siblings('.tab').addClass('hidden')

    $('#tab-about').removeClass('hidden')
    deselectAddNewSelectors()

$(document).ready(main)
