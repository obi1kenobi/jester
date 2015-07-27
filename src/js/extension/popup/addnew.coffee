logger = require('../../lib/util/logging').logger(['ext', 'popup', 'addnew'])

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


AddNew =
  setup: () ->
    setupAddNewSelectors()
    setupAddNewButton()

module.exports = AddNew
