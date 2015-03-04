changeColor = (r, g, b) ->
  color = '#' + r.toString(16) + g.toString(16) + b.toString(16)
  document.getElementById("btn-login").style.background = color

randomizeColor = () ->
  colors = (getRandomInt(0, 255) for i in [0..2])
  changeColor(colors...)

getRandomInt = (min, max) ->
  Math.floor(Math.random() * (max - min + 1)) + min;

# window.onload fires every time the popup window is shown
window.onload = randomizeColor
