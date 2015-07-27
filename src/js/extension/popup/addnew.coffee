logger = require('../../lib/util/logging').logger(['ext', 'popup', 'addnew'])

setupAddNewSelectors = () ->
  handler = () ->
    $(this).siblings().removeClass('active')
    $(this).addClass('active')
    $('#addnew-creds').removeClass('hidden')

  $('#addnew-yahoo').click handler
  $('#addnew-stackexchange').click handler

setupAddNewButton = (sender) ->
  $('#addnew-setup').click createAddNewClickedHandler(sender)

getSelectedServiceName = () ->
  if $('#addnew-yahoo').hasClass('active')
    return 'yahoo'
  else if $('#addnew-stackexchange').hasClass('active')
    return 'stackExchange'
  else
    throw new Error('No service requested!')

createAddNewClickedHandler = (sender, storePassword) ->
  return () ->
    username = $('#addnew-username').val()
    password = $('#addnew-password').val()

    service = getSelectedServiceName()
    profile = uuid.v1()

    sender.sendAddNewMessage profile, storePassword, service, username, password, () ->
      logger('Response received')


AddNew =
  setup: (sender, storePassword) ->
    setupAddNewSelectors()
    setupAddNewButton(sender, storePassword)

module.exports = AddNew
