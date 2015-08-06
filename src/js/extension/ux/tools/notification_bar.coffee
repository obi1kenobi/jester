logger          = require('../../../lib/util/logging').logger(['ext', 'ux', 'not'])


class NotificationBar
  constructor: (@jqElement) ->
    @innerElement = @jqElement.children('.alert-inner')
    @timer = null

  ###
  @param strongText {String|null} bolded text to display before message
                                  no bolded text displayed if null
  @param message    {String} notification message to display
  @param duration   {Number} milliseconds before hiding the notification
  @param type       {String} one of 'success', 'info', 'warning', 'danger'
  ###
  display: (strongText, message, duration, type) ->
    if @timer?
      clearTimeout @timer
      @jqElement.addClass('alert-hidden')
      @jqElement.removeClass('alert-success')
      @jqElement.removeClass('alert-info')
      @jqElement.removeClass('alert-warning')
      @jqElement.removeClass('alert-danger')
      @innerElement.text('')
      @timer = null

    if strongText?
      @innerElement.append("<strong>#{strongText}</strong> #{message}")
    else
      @innerElement.append(message)

    @jqElement.addClass("alert-#{type}")
    @jqElement.removeClass('alert-hidden')

    timeoutHandler = () ->
      @jqElement.addClass('alert-hidden')
      @jqElement.removeClass("alert-#{type}")
      @innerElement.text('')
      @timer = null

    @timer = setTimeout timeoutHandler.bind(this), duration


module.exports = NotificationBar
