logger = require('../lib/util/logging').logger(['ext', 'popup_main'])

main = () ->
  setupHandlers()

setupHandlers = () ->
  setupTabs()
  setupAddNewSelectors()

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

$(document).ready(main)
