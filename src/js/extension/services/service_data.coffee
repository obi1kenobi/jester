# Domain info specification:
#   Each domain has three attributes: login, changePwd, logout
#   Each of these has an url and type, and optional args.
#   If type == 'form-noframe', args has the element IDs of the necessary fields,
#     and the operation cannot be performed in a frame (must be in the main window).
#   If type == 'hit', it is sufficient to just visit the URL (e.g. as an Image src).
ServiceData =
  yahoo:
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
    logout:
      url: 'https://login.yahoo.com/config/login?logout=1'
      type: 'hit'
  stackExchange:
    login:
      url: 'https://openid.stackexchange.com/account/login'
      type: 'form-noframe'
      args:
        username: '#email'
        password: '#password'
        submit: '.orange'
    changePwd:
      url: 'https://openid.stackexchange.com/account/password-reset'
      type: 'form-noframe'
      args:
        password: '#password'
        confirmPassword: '#password2'
        submit: '.orange'
    logout:
      url: 'https://openid.stackexchange.com/account/logout'
      type: 'form-noframe'
      args:
        submit: '.orange'


module.exports = ServiceData
