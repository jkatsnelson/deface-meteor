require = __meteor_bootstrap__.require;
fs = require('fs')
path = require('path')

httpGetPath = 'node_modules/http-get'

base = path.resolve '.'
if base == '/'
  base = path.dirname global.require.main.filename

publicPath = path.resolve base+'/public/'+httpGetPath
staticPath = path.resolve base+'/static/'+httpGetPath

if fs.existsSync publicPath
  httpGet = require publicPath
else if fs.existsSync staticPath
  HttpGet = require staticPath
else console.log 'node_modules not found'


Meteor.methods
	pull_image: (url) ->
		id = url.split('/').pop()
		Images.insert({image_id: id})
		file = '/Users/john/Projects/deface/public/image.jpg'
		httpGet.get url: url, file, (error, res) ->
			if error then console.error error
			else console.log "file downloaded at: " + result.file
Meteor.Router.add '/public/:id', 'GET', (id) ->
	img = Images.findOne({image_id: id}).jpeg
	console.log img
	return [200, {'Content-Type' : 'image/jpeg'}, img]