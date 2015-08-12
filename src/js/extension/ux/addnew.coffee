uuid             = require('../../../deps/uuid')
logger           = require('../../lib/util/logging').logger(['ext', 'ux', 'addnew'])
sender           = require('../messaging/ui/sender')
unauthTimer      = require('./tools/unauth_timer')
ephemeralStorage = require('./tools/ephemeral_storage')
NotificationBar  = require('./tools/notification_bar')
profiles         = require('./profiles')

notification = new NotificationBar($('#alert-addnew'))

setupAddNewSelectors = () ->
  handler = () ->
    unauthTimer.reset()
    $(this).siblings().removeClass('active')
    $(this).addClass('active')
    $('#addnew-creds').removeClass('hidden')
    $('#addnew-username').val('')
    $('#addnew-password').val('')

  $('#addnew-yahoo').click handler
  # $('#addnew-dockerhub').click handler

setupAddNewButton = () ->
  $('#addnew-setup').click(addNewClickedHandler)

getSelectedServiceName = () ->
  if $('#addnew-yahoo').hasClass('active')
    return 'Yahoo'
  # else if $('#addnew-dockerhub').hasClass('active')
  #   return 'DockerHub'
  else
    throw new Error('No service requested!')

addNewClickedHandler = () ->
  unauthTimer.reset()
  username = $('#addnew-username').val()
  password = $('#addnew-password').val()

  service = getSelectedServiceName()
  profile = uuid.v1()
  {storePassword} = ephemeralStorage

  message = "Adding a #{service} profile..."
  notification.display('Please wait', message, 30000, 'info')

  sender.sendAddNewMessage profile, storePassword, service, \
                           username, password, (err, res) ->
    if err?
      message = "Couldn't add profile. " + \
                "Please ensure your credentials are correct."
      notification.display('Error!', message, 60000, 'danger')
      return
    profiles.addProfile(profile, {service, username, valid: true})
    $('#addnew-username').val('')
    $('#addnew-password').val('')
    message = "#{service} profile added successfully."
    notification.display('Success!', message, 15000, 'success')

AddNew =
  setup: () ->
    setupAddNewSelectors()
    setupAddNewButton()


module.exports = AddNew
