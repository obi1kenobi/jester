# From: https://developer.mozilla.org/en-US/docs/Web/JavaScript/Guide/Regular_Expressions
quote = (str) ->
  return str.replace(/[.*+?^${}()|[\]\\]/g, '\\$&')

exact = (str) ->
  return new RegExp('^' + quote(str) + '$')

startsWith = (str) ->
  return new RegExp('^' + quote(str) + '.*')

# Service info specification:
#   Each service has two attributes: login, changePwd
#   Each of these has an url and type, and optional args.
#   If type == 'form_redirect', args has the element IDs of the necessary fields,
#     and if the submission is successful, the server will redirect to the specified URL
ServiceData =
  Yahoo:
    login:
      url: 'https://login.yahoo.com/'
      type: 'form_redirect'
      args:
        input:
          username: '#login-username'
          password: '#login-passwd'
        submit: '#login-signin'
        onSuccessURL: exact('https://www.yahoo.com/')
    changePwd:
      url: 'https://edit.yahoo.com/config/change_pw'
      type: 'form_redirect'
      args:
        input:
          newPassword: '#password'
          confirmPassword: '#password-confirm'
        submit: '#primary-cta'
        onSuccessURL: startsWith('https://edit.yahoo.com/config/change_pw?.done=')
  'Hacker News (YCombinator)':
    login:
      url: 'https://news.ycombinator.com/login'
      type: 'form_redirect'
      args:
        input:
          username: 'input[name="acct"]'
          password: 'input[name="pw"]'
        submit: 'input[value="login"]'
        onSuccessURL: exact('https://news.ycombinator.com/')
    changePwd:
      url: 'https://news.ycombinator.com/changepw'
      type: 'form_redirect'
      args:
        input:
          oldPassword: 'input[name="oldpw"]'
          newPassword: 'input[name="pw"]'
        submit: 'input[value="Change"]'
        onSuccessURL: exact('https://news.ycombinator.com/news')


  # Firebase:
  #   login:
  #     url: 'https://www.firebase.com/login/'
  #     type: 'form_redirect'
  #     args:
  #       input:
  #         username: '#login-email'
  #         password: '#login-password'
  #       submit: '#login-button'
  #       onSuccessURL: exact('https://www.firebase.com/account/')
  #   changePwd:
  #     url: 'https://www.firebase.com/change_password.html'
  #     type: 'same_page_element_exists'
  #     args:
  #       input:
  #         oldPassword: '#current'
  #         newPassword: '#password'
  #         confirmPassword: '#confirm'
  #       submit: 'input[value="Change Password"]'
  #       onSuccessElement: 'p.alert.alert-success' + \
  #                         ':contains("Password changed successfully.")'


  # DockerHub:
  #   login:
  #     url: 'https://hub.docker.com/login/'
  #     type: 'form_redirect'
  #     args:
  #       input:
  #         username: '.DUXInput-b__duxInput___l1DEO' + \
  #                   '[data-reactid$=".1.0.1.0.0.0.0.0.1.0.0"]'
  #         password: '.DUXInput-b__duxInput___l1DEO' + \
  #                   '[data-reactid$=".1.0.1.0.0.0.0.0.2.0.0"]'
  #       submit: '.button[data-reactid$=".1.0.1.0.0.0.0.0.3.0"]'
  #       onSuccessURL: new RegExp('^' + quote('https://hub.docker.com/') + '$')
  #   changePwd:
  #     url: 'https://hub.docker.com/account/settings/'
  #     type: 'form_redirect'
  #     args:
  #       input:
  #         oldPassword: '.DUXInput__duxInput___10RXU' + \
  #                      '[data-reactid$=".1.1.1.0.2.1.0.0.0.0.0.0.0"]'
  #         newPassword: '.DUXInput__duxInput___10RXU' + \
  #                      '[data-reactid$=".1.1.1.0.2.1.0.0.0.0.1.0.0"]'
  #         confirmPassword: '.DUXInput__duxInput___10RXU' + \
  #                      '[data-reactid$=".1.1.1.0.2.1.0.0.0.0.2.0.0"]'
  #       submit: '.button[data-reactid$=".1.1.1.0.2.1.0.0.0.1.0.0.0"]'
  #       onSuccessURL: new RegExp('^' + \
  #         quote('https://hub.docker.com/account/password-reset-confirm/success/') + \
  #         '$')



module.exports = ServiceData
