uuid             = require('../../../deps/uuid')
logger           = require('../../lib/util/logging').logger(['ext', 'ux', 'addnew'])
sender           = require('../messaging/ui/sender')
serviceData      = require('../services/service_data')
unauthTimer      = require('./tools/unauth_timer')
ephemeralStorage = require('./tools/ephemeral_storage')
NotificationBar  = require('./tools/notification_bar')
profiles         = require('./profiles')

notification = new NotificationBar($('#alert-addnew'))

createAddNewOption = (service, handler) ->
  element = $("<a href=\"#\" class=\"list-group-item\">#{service}</a>")
  element.data('service', service)
  $('#addnew-selector').append(element)
  element.click(handler)

setupAddNewSelectors = () ->
  handler = () ->
    unauthTimer.reset()
    $(this).siblings().removeClass('active')
    $(this).addClass('active')
    $('#addnew-creds').removeClass('hidden')
    $('#addnew-username').val('')
    $('#addnew-password').val('')

  for service in Object.keys(serviceData)
    createAddNewOption(service, handler)

setupAddNewButton = () ->
  $('#addnew-setup').click(addNewClickedHandler)

addNewClickedHandler = () ->
  unauthTimer.reset()
  username = $('#addnew-username').val()
  password = $('#addnew-password').val()

  service = $('#addnew-selector').children('.active').data('service')
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
