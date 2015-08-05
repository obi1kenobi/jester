logger           = require('../../lib/util/logging').logger(['ext', 'ux', 'addnew'])
sender           = require('../messaging/ui/sender')
profiles         = require('./profiles')
unauthTimer      = require('./unauth_timer')
ephemeralStorage = require('./ephemeral_storage')

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

setupAddNewButton = () ->
  $('#addnew-setup').click(addNewClickedHandler)

getSelectedServiceName = () ->
  if $('#addnew-yahoo').hasClass('active')
    return 'Yahoo'
  else if $('#addnew-dockerhub').hasClass('active')
    return 'DockerHub'
  else
    throw new Error('No service requested!')

addNewClickedHandler = () ->
  unauthTimer.reset()
  username = $('#addnew-username').val()
  password = $('#addnew-password').val()

  service = getSelectedServiceName()
  profile = uuid.v1()
  {storePassword} = ephemeralStorage

  sender.sendAddNewMessage profile, storePassword, service, username, password, () ->
    profiles.addProfile(profile, {service, username})
    $('#tabhead-home').click()

AddNew =
  setup: () ->
    setupAddNewSelectors()
    setupAddNewButton()


module.exports = AddNew
