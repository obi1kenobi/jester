console.log "Hello World"

# hack to attach globals to the correct variable
# both in Node and the browser
exporter = exports ? this

