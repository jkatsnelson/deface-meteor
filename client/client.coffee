Meteor.startup ->
  Session.set('draw_mode', 'Draw mode is off')
  window.canvas = new fabric.Canvas 'c'
grab_image = (url, id) ->
  Meteor.call 'get_image', url, id, (err, result) ->
    if err then console.error err
    render_image result

render_image = (image) ->
  console.log image
  $('#image').remove()
  window.canvas.clear()
  image = Meteor.render ->
    '<image src="data:image/jpeg;base64,'+image+'" id="image">'
  window.document.body.appendChild(image)
  setTimeout ->
    imgElement = window.document.getElementById 'image'
    imgInstance = new fabric.Image imgElement,
      top: $('img').height() / 2
      left: $('img').width() / 2
    window.canvas.add imgInstance
    window.canvas.setWidth($('img').width())
    window.canvas.setHeight($('img').height())
  , 2000

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

Template.fabric.draw_mode = ->
  Session.get('draw_mode')

Meteor.Router.add
  'tests' : 'tests'
  '/': 'main'

Template.menu.events
  "click .deface": (e)->
    e.preventDefault()
    url = $('#url').val()
    id = url.split('/').pop()
    Session.set('id', id)
    grab_image url, id
  "click .share": (e) ->
    e.preventDefault()
    share()
  "click .erase": (e) ->
    e.preventDefault()
    Meteor.call 'remove_images'

Template.fabric.events
  'click .draw': (e)->
    e.preventDefault()
    canvas = window.canvas
    if canvas.isDrawingMode
      canvas.isDrawingMode = false
      Session.set('draw_mode', 'Draw mode is off.')
    else
      canvas.isDrawingMode = true
      Session.set('draw_mode', 'Draw mode is on.')
  'change .line_width': (e)->
    e.preventDefault()
    window.canvas.freeDrawingLineWidth = e.target.value
  'click .color': (e)->
    e.preventDefault()
    color = e.srcElement.innerText
    window.canvas.freeDrawingColor = color
  'click .black_cat': (e)->
    e.preventDefault()
    cat = new fabric.loadSVGFromURL 'black_cat.svg', (objects, options) ->
      shape = fabric.util.groupSVGElements objects, options
      window.canvas.add shape.scale 0.8
  'click .octocat': (e)->
    e.preventDefault()
    cat = new fabric.loadSVGFromURL 'git-cat.svg', (objects, options) ->
      shape = fabric.util.groupSVGElements objects, options
      window.canvas.add shape.scale 0.6