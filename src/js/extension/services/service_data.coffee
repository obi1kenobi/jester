# Domain info specification:
#   Each domain has three attributes: login, changePwd, logout
#   Each of these has an url and type, and optional args.
#   If type == 'form-noframe', args has the element IDs of the necessary fields,
#     and the operation cannot be performed in a frame (must be in the main window).
#   If type == 'hit', it is sufficient to just visit the URL (e.g. as an Image src).
ServiceData =
  Yahoo:
    login:
      url: 'https://login.yahoo.com/'
      type: 'form-noframe'
      args:
        username: '#login-username'
        password: '#login-passwd'
        submit: '#login-signin'
    changePwd:
      url: 'https://edit.yahoo.com/config/change_pw'
      type: 'form-noframe'
      args:
        password: '#password'
        confirmPassword: '#password-confirm'
        submit: '#primary-cta'
  DockerHub:
    login:
      url: 'https://hub.docker.com/account/login/'
      type: 'form-noframe'
      args:
        username: '#id_username'
        password: '#id_password'
        submit: '.btn-primary'
    changePwd:
      url: 'https://hub.docker.com/account/change-password/'
      type: 'form-noframe'
      args:
        oldPassword: '#id_old_password'
        password: '#id_new_password1'
        confirmPassword: '#id_new_password2'
        submit: '.btn-primary'


module.exports = ServiceData
