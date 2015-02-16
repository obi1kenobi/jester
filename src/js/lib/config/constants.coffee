Constants =
  MIN_PASSWORD_BYTES: 8

if module?.exports?
  # we're in Node
  module.exports = Constants
else
  # running in browser
  define(Constants)
