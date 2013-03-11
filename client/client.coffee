image_to_canvas = () ->
  canvas = new fabric.Canvas 'c'
  imgElement = document.getElementById 'image'
  imgInstance = new fabric.Image imgElement,
    left: 100
    top: 100
    opacity: .85
  canvas.add(imgInstance)
  canvas.isDrawingMode = true

Template.canvas.image = ->
  return 'data:image/jpeg;base64,' + Session.get('image')
Template.canvas.events
  "click .show": (e) ->
    e.preventDefault()
    pull_image_from_db('6F7JytV.jpg')
  "click .use": (e) ->
    e.preventDefault()
    image_to_canvas()

Meteor.Router.add({
  'tests' : 'tests'
  '/': 'main'
})

get_image_from_url = (url) ->
  Meteor.call 'get_image', url

pull_image_from_db = (id) ->
  Meteor.call 'pull_image', id, (error, result) ->
    if error then console.error error
    Session.set('image', result)

Template.grab_link.events
  "click .submit": (e)->
    e.preventDefault()
    get_image_from_url 'http://i.imgur.com/6F7JytV.jpg'