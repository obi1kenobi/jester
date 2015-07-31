logger = require('../../lib/util/logging').logger(['ext', 'ux', 'addnew'])

setupAddNewSelectors = (resetUnauthTimer) ->
  handler = () ->
    resetUnauthTimer()
    $(this).siblings().removeClass('active')
    $(this).addClass('active')
    $('#addnew-creds').removeClass('hidden')

  $('#addnew-yahoo').click handler
  $('#addnew-stackexchange').click handler

setupAddNewButton = (sender, storePassword, resetUnauthTimer) ->
  handler = createAddNewClickedHandler(sender, storePassword, resetUnauthTimer)
  $('#addnew-setup').click(handler)

getSelectedServiceName = () ->
  if $('#addnew-yahoo').hasClass('active')
    return 'yahoo'
  else if $('#addnew-stackexchange').hasClass('active')
    return 'stackExchange'
  else
    throw new Error('No service requested!')

createAddNewClickedHandler = (sender, storePassword, resetUnauthTimer) ->
  return () ->
    resetUnauthTimer()
    username = $('#addnew-username').val()
    password = $('#addnew-password').val()

    service = getSelectedServiceName()
    profile = uuid.v1()

    sender.sendAddNewMessage profile, storePassword, service, username, password, () ->
      logger('Response received')


AddNew =
  setup: (sender, storePassword, resetUnauthTimer) ->
    setupAddNewSelectors(resetUnauthTimer)
    setupAddNewButton(sender, storePassword, resetUnauthTimer)


module.exports = AddNew
