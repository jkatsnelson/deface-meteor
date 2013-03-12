grab_image = (url) ->
  id = url.split('/').pop()
  watch_images = Images.find({image_id: id}).observe
    added: (document) ->
      render_image document
      watch_images.stop()
  Session.set('id', id)
  Meteor.call 'get_image', url, id

render_image = (document)->
  console.log document
  image = Meteor.render ->
    '<image src="data:image/jpeg;base64,'+document.jpeg+'" id="image">'
  $('#image').remove()
  window.document.body.appendChild(image)
  window.canvas = new fabric.Canvas 'c'
  imgElement = window.document.getElementById 'image'
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

Template.menu.url = ->
  if not Session.get('link') then return 'Share'
  return Session.get('link')

Meteor.Router.add
  'tests' : 'tests'
  '/': 'main'

Template.menu.events
  "click .deface": (e)->
    e.preventDefault()
    grab_image $('.url').val()
  "click .share": (e) ->
    e.preventDefault()
    share()
  "click .erase": (e) ->
    e.preventDefault()
    Meteor.call 'remove_images'