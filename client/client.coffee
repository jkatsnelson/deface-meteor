Meteor.startup ->
  canvas = new fabric.Canvas('c')
  path = "6F7JytV.jpg"
  fabric.Image.fromURL path, (img) ->
    img.left = 195
    canvas.add(img)
    canvas.isDrawingMode = true
    window.deface = canvas

Meteor.Router.add({
  '/tests' : 'tests'
  '/': 'main'
})

getImage = (url) ->
  Meteor.call('pull_image', url)

Template.grab_link.events
  "click .submit": (e)->
    e.preventDefault()
    getImage('http://i.imgur.com/6F7JytV.jpg')