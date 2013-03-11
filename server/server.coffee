require = __meteor_bootstrap__.require;
fs = require('fs')
path = require('path')

requestPath = 'node_modules/request'

base = path.resolve '.'
if base == '/'
  base = path.dirname global.require.main.filename

publicPath = path.resolve base+'/public/'+requestPath
staticPath = path.resolve base+'/static/'+requestPath

if fs.existsSync publicPath
  request = require publicPath
else if fs.existsSync staticPath
  request = require staticPath
else console.log 'node_modules not found'


Meteor.methods
	pull_image: (url) ->
		id = url.split('/').pop()
		Images.insert({image_id: id})
		options = 'encoding': 'base64'
		Meteor.http.get url, options, (error, result) ->
			fs.writeFileSync('images.jpg', result.content)
			if error then return console.error error
			Images.update({image_id: id}, {image_id: id, jpeg: result.content})

Meteor.Router.add '/public/:id', 'GET', (id) ->
	img = Images.findOne({image_id: id}).jpeg
	return [200, {'Content-Type' : 'image/jpeg'}, img]