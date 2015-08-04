logger           = require('../../lib/util/logging').logger(['ext', 'ux', 'addnew'])
sender           = require('../messaging/ui/sender')
unauthTimer      = require('./unauth_timer')

setupAddNewSelectors = () ->
  handler = () ->
    unauthTimer.reset()
    $(this).siblings().removeClass('active')
    $(this).addClass('active')
    $('#addnew-creds').removeClass('hidden')
    $('#addnew-username').val('')
    $('#addnew-password').val('')

  $('#addnew-yahoo').click handler
  $('#addnew-dockerhub').click handler

setupAddNewButton = (storePassword) ->
  handler = createAddNewClickedHandler(storePassword)
  $('#addnew-setup').click(handler)

getSelectedServiceName = () ->
  if $('#addnew-yahoo').hasClass('active')
    return 'Yahoo'
  else if $('#addnew-dockerhub').hasClass('active')
    return 'DockerHub'
  else
    throw new Error('No service requested!')

createAddNewClickedHandler = (storePassword) ->
  return () ->
    unauthTimer.reset()
    username = $('#addnew-username').val()
    password = $('#addnew-password').val()

    service = getSelectedServiceName()
    profile = uuid.v1()

    sender.sendAddNewMessage profile, storePassword, service, username, password, () ->
      logger('Response received')


AddNew =
  setup: (storePassword) ->
    setupAddNewSelectors()
    setupAddNewButton(storePassword)


module.exports = AddNew
