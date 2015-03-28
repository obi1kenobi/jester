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
        usernameId: 'login-username'
        passwordId: 'login-passwd'
        submitId: 'login-signin'
    changePwd:
      url: 'https://edit.yahoo.com/config/change_pw'
      type: 'form-noframe'
      args:
        passwordId: 'password'
        confirmPasswordId: 'password-confirm'
        submitId: 'primary-cta'
    logout:
      url: 'https://login.yahoo.com/config/login?logout=1'
      type: 'hit'

Service =
  getInfo: (name) ->
    data = ServiceData[name]
    if !data?
      throw new Error("Unknown service name: #{name}")
    return data

module.exports = Service
