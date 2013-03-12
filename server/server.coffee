require = __meteor_bootstrap__.require;
fs = require('fs')
path = require('path')
base = path.resolve '.'
isBundle = fs.existsSync base + '/bundle'
modulePath = base + (if isBundle then '/bundle/static' else '/public') + '/node_modules'
request = require(modulePath + '/request')

Meteor.methods
	get_image: (url, id) ->
		options =
			url: url
			encoding: null
		request.get options, (error, result, body) ->
			if error then return console.error error
			jpeg = body.toString('base64')
			Fiber ->
				Images.insert {image_id: id, jpeg: jpeg}
			.run()
	remove_images: () ->
		Images.remove({})