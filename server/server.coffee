require = __meteor_bootstrap__.require;
fs = require('fs')
path = require('path')
Future = require('fibers/future')
base = path.resolve '.'
isBundle = fs.existsSync base + '/bundle'
modulePath = base + (if isBundle then '/bundle/static' else '/public') + '/node_modules'
request = require(modulePath + '/request')

Meteor.methods
	get_image: (url, id) ->
		fut = new Future()
		console.log url
		options =
			url: url
			encoding: null
		request.get options, (error, result, body) ->
			if error then return console.error error
			jpeg = body.toString('base64')
			fut.ret jpeg
			console.log 'made a get request'
		return fut.wait()
	remove_images: () ->
		console.log 'eraseyrasey'
		Images.remove({})