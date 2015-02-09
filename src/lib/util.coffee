Util =
  log: console.log

if module?.exports?
  # export for node.js
  module.exports = Util
else
  # export for browser
  this.jester.util = Util
