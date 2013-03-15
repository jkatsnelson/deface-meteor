grab_image = (url, id) ->
  Meteor.call 'get_image', url, id, (err, result) ->
    if err then console.error err
    render_image result

grab_room = (room) ->


render_image = (image) ->
  window.canvas = new fabric.Canvas 'c'
  $('#image').remove()
  window.canvas.clear()
  image = Meteor.render ->
    '<image src="data:image/jpeg;base64,'+image+'" id="image">'
  setTimeout ->
    window.document.body.appendChild(image)
    imgElement = window.document.getElementById 'image'
    imgInstance = new fabric.Image imgElement,
      top: $('img').height() / 2
      left: $('img').width() / 2
    window.canvas.add imgInstance
    window.canvas.setWidth($('img').width())
    window.canvas.setHeight($('img').height())
    window.canvas.on 'mouse:up', (options) ->
      Images.insert {id: Session.get('room'), img: window.canvas.toJSON()}
    Session.set('draw_mode', true)
  , 1
share = (name) ->
  Session.set('share_pressed', true)
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

Template.main.image = ->
  Session.get('image')

Template.main.draw_mode = ->
  if Session.get('draw_mode')
    if window.canvas
      window.canvas.isDrawingMode = true
  else
    if window.canvas 
      window.canvas.isDrawingMode = false

Template.draw_button.draw_mode = ->
  if Session.get('draw_mode')
    return 'btn btn-large btn-success draw'
  else
    return 'btn btn-large draw btn-inverse'
Template.share.share_pressed = ->
  Session.get('share_pressed')

Template.share.url = ->
  Session.get('link')

Meteor.Router.add
  'tests' : 'tests'
  '/': 'main'

Template.hero_menu.events
  "click .deface": (e) ->
    e.preventDefault()
    url = $('.url').val()
    id = url.split('/').pop()
    Session.set('id', id)
    Session.set 'image', true
    Session.set 'room', $('.room').val()
    grab_image url, id
  "click .room_button": (e) ->
    e.preventDefault()
    Session.set('room', $('.room').val())
    grab_room room

Template.menu.events
  "click .deface": (e) ->
    e.preventDefault()
    url = $('#url').val()
    id = url.split('/').pop()
    Session.set('id', id)
    grab_image url, id

Template.share.events
  "click .share": (e) ->
    e.preventDefault()
    share()

Template.draw_button.events
  'click .draw': (e)->
    e.preventDefault()
    if window.canvas.isDrawingMode
      Session.set('draw_mode', false)
    else
      Session.set('draw_mode', true)

Template.draw_menu.events
  'change .line_width': (e)->
    e.preventDefault()
    window.canvas.freeDrawingLineWidth = e.target.value
  'click .color': (e)->
    e.preventDefault()
    window.canvas.freeDrawingColor = e.srcElement.innerText

Template.cats.events
  'click .black_cat': (e)->
    e.preventDefault()
    Session.set('draw_mode', false)
    cat = new fabric.loadSVGFromURL 'black_cat.svg', (objects, options) ->
      shape = fabric.util.groupSVGElements objects, options
      window.canvas.add shape.scale 0.2
  'click .octocat': (e)->
    e.preventDefault()
    Session.set('draw_mode', false)
    cat = new fabric.loadSVGFromURL 'git-cat.svg', (objects, options) ->
      shape = fabric.util.groupSVGElements objects, options
      window.canvas.add shape.scale 0.6