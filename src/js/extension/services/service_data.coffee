# From: https://developer.mozilla.org/en-US/docs/Web/JavaScript/Guide/Regular_Expressions
quote = (str) ->
  return str.replace(/[.*+?^${}()|[\]\\]/g, '\\$&')

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
        onSuccessURL: new RegExp('^' + quote('https://www.yahoo.com/') + '$')
    changePwd:
      url: 'https://edit.yahoo.com/config/change_pw'
      type: 'form_redirect'
      args:
        input:
          newPassword: '#password'
          confirmPassword: '#password-confirm'
        submit: '#primary-cta'
        onSuccessURL:
          new RegExp('^' + \
                     quote('https://edit.yahoo.com/config/change_pw?.done=') + \
                     '.*')
  DockerHub:
    login:
      url: 'https://hub.docker.com/account/login/'
      type: 'form_redirect'
      args:
        input:
          username: '#id_username'
          password: '#id_password'
        submit: '.btn-primary'
        onSuccessURL: new RegExp('^' + quote('https://hub.docker.com/') + '$')
    changePwd:
      url: 'https://hub.docker.com/account/change-password/'
      type: 'form_redirect'
      args:
        input:
          oldPassword: '#id_old_password'
          newPassword: '#id_new_password1'
          confirmPassword: '#id_new_password2'
        submit: '.btn-primary'
        onSuccessURL: \
          new RegExp('^' + \
                     quote('https://hub.docker.com/account/change-password-done/') + \
                     '$')



module.exports = ServiceData
