image_to_canvas = () ->
  window.canvas = new fabric.Canvas 'c'
  imgElement = document.getElementById 'image'
  imgInstance = new fabric.Image imgElement,
    left: 464
    top: 384
  window.canvas.add(imgInstance)
  window.canvas.isDrawingMode = true
  window.canvas.setWidth($('img').width())
  window.canvas.setHeight($('img').height())

share = ->
  try
    img = window.canvas.toDataURL("image/jpeg", 0.9).split(",")[1]
  catch e
    img = window.canvas.toDataURL().split(",")[1]
  
  # open the popup in the click handler so it will not be blocked
  w = window.open()
  w.document.write "Uploading..."
  
  # upload to imgur using jquery/CORS
  # https://developer.mozilla.org/En/HTTP_access_control
  
  # get your key here, quick and fast http://imgur.com/register/api_anon
  Meteor.http.post "http://api.imgur.com/2/upload.json",
    data:
      type: "base64"
      key: "3581999bd2d6f55b7feb8e94724d9944"
      name: "neon.jpg"
      title: "test title"
      caption: "test caption"
      image: img
    dataType: "json"
  ).success((data) ->
    w.location.href = data["upload"]["links"]["imgur_page"]
  ).error ->
    alert "Could not reach api.imgur.com. Sorry :("
    w.close()
 
  
Template.image.image = ->
  return 'data:image/jpeg;base64,' + Session.get('image')

Meteor.Router.add({
  'tests' : 'tests'
  '/': 'main'
})

get_image_from_url = (url) ->
  Meteor.call 'get_image', url

pull_image_from_db = (id) ->
  Session.set('id', id)
  Meteor.call 'pull_image', id, (error, result) ->
    if error then console.error error
    Session.set('image', result)

Template.grab_link.events
  "click .submit": (e)->
    e.preventDefault()
    get_image_from_url 'http://i.imgur.com/6F7JytV.jpg'
  "click .erase": (e) ->
    e.preventDefault()
    Meteor.call 'remove_images'
  "click .preview": (e) ->
    e.preventDefault()
    pull_image_from_db('6F7JytV.jpg')
  "click .deface": (e) ->
    e.preventDefault()
    image_to_canvas()