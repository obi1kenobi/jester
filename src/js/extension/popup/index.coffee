logger          = require('../../lib/util/logging').logger(['ext', 'popup_main'])
sender          = require('../messaging/ui/sender')
popupAuth       = require('./auth')
popupProfiles   = require('./profiles')

main = () ->
  setupHandlers()

setupHandlers = () ->
  popupAuth.setupAuth sender, (err, password) ->
    if err?
      logger("Unexpected error returned from setupAuth", err)
      return
    else
      popupProfiles.populate(sender, password)

  setupTabs()
  setupAddNewSelectors()
  setupAddNewButton()

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

setupAddNewSelectors = () ->
  handler = () ->
    $(this).siblings().removeClass('active')
    $(this).addClass('active')
    $('#addnew-creds').removeClass('hidden')

  $('#addnew-yahoo').click handler
  $('#addnew-stackexchange').click handler

setupAddNewButton = () ->
  createProfileName = (service, username) ->
    return "#{service}|#{username}"

  getSelectedServiceName = () ->
    if $('#addnew-yahoo').hasClass('active')
      return 'yahoo'
    else if $('#addnew-stackexchange').hasClass('active')
      return 'stackexchange'
    else
      throw new Error('No service requested!')

  $('#addnew-setup').click () ->
    username = $('#addnew-username').val()
    password = $('#addnew-password').val()

    service = getSelectedServiceName()
    profile = createProfileName(service, username)

    sender.sendAddNewMessage profile, username, password, () ->
      logger('Response received')


$(document).ready(main)
