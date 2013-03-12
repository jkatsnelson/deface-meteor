get_image_from_url = (url) ->
  id = url.split('/').pop()
  Session.set('id', id)
  Meteor.call 'get_image', url, id

pull_image_from_db = (id) ->
  Session.set('start', true)
  Meteor.call 'pull_image', id, (error, result) ->
    if error then console.error error
    Session.set('image', result)

image_to_canvas = () ->
  window.canvas = new fabric.Canvas 'c'
  imgElement = document.getElementById 'image'
  imgInstance = new fabric.Image imgElement,
    top: $('img').height() / 2
    left: $('img').width() / 2
  window.canvas.add(imgInstance)
  window.canvas.isDrawingMode = true
  window.canvas.setWidth($('img').width())
  window.canvas.setHeight($('img').height())

share = (name) ->
  if not name then name is Session.get('id')
  try
    img = window.canvas.toDataURL("image/jpeg", 0.9).split(",")[1]
  catch e
    img = window.canvas.toDataURL().split(",")[1]
  Meteor.http.post "https://api.imgur.com/3/image",
    headers:
      'Authorization': 'Client-ID d838931eecf2cf8'
    data:
      type: "base64"
      name: name
      image: img
  , (err, data) ->
    if err then console.error err
    data = JSON.parse(data.content)
    Session.set 'link', data.data.link

Template.image.image = ->
  return 'data:image/jpeg;base64,' + Session.get('image')

Template.give_link.url = ->
  if not Session.get('link') then return 'Share'
  return Session.get('link')

Template.main.start = ->
  Session.get('start')

Meteor.Router.add
  'tests' : 'tests'
  '/': 'main'

Template.grab_link.events
  "click .submit": (e)->
    e.preventDefault()
    get_image_from_url $('.url').val()
  "click .erase": (e) ->
    e.preventDefault()
    Meteor.call 'remove_images'
  "click .preview": (e) ->
    e.preventDefault()
    pull_image_from_db Session.get('id')
  "click .deface": (e) ->
    e.preventDefault()
    image_to_canvas()
  "click .share": (e) ->
    e.preventDefault()
    share()