logger = require('../lib/util/logging').logger(['ext', 'popup_main'])
sender = require('./messaging/ui/sender')

main = () ->
  setupHandlers()

setupHandlers = () ->
  setupAuth()
  setupTabs()
  setupAddNewSelectors()
  setupAddNewButton()

setupAuth = () ->
  populateProfiles = () ->
    logger("Populating profiles...")

  authCleanup = () ->
    logger("Cleaning up auth...")
    $('#jester-auth').addClass('hidden')
    $('#jester-authed').removeClass('hidden')
    populateProfiles()

  handleAuthSubmit = (event) ->
    event.preventDefault()
    password = $('#auth-password').val()
    sender.sendGetConfigMessage password, (err, config) ->
      if err?
        logger("Received error on sendGetConfigMessage, " + \
               "likely wrong password", err)
        return false
      else
        authCleanup()

  handleSetupSubmit = (event) ->
    # we never want to leave the page
    event.preventDefault()

    password = $('#auth-setup-password').val()
    confirmPassword = $('#auth-setup-confpassword').val()

    if password != confirmPassword
      logger('Entered passwords do not match!')
      return false

    logger('Passwords match, setting up...')
    sender.sendSetConfigMessage password, {}, (err) ->
      if err?
        logger('Received error on sendSetConfigMessage', err)
        return
      else
        authCleanup()


  sender.sendConfigExistsMessage (err, exists) ->
    if err?
      logger('Received error on sendConfigExistsMessage', err)
      return

    logger("Config exists: #{exists}")
    if exists
      $('#jester-enter').removeClass('hidden')
      $('#auth-creds').submit(handleAuthSubmit)
    else
      $('#jester-setup').removeClass('hidden')
      $('#auth-setup-creds').submit(handleSetupSubmit)

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
