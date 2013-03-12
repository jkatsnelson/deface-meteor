require = __meteor_bootstrap__.require;
fs = require('fs')
path = require('path')
base = path.resolve '.'
isBundle = fs.existsSync base + '/bundle'
modulePath = base + (if isBundle then '/bundle/static' else '/public') + '/node_modules'
request = require(modulePath + '/request')

Meteor.methods
	get_image: (url, id) ->
		Images.insert({image_id: id})
		options =
			url: url
			encoding: null
		request.get options, (error, result, body) ->
			if error then return console.error error
			Fiber ->
				Images.update({image_id: id}, {image_id: id, jpeg: body})
			.run()
	pull_image: (id) ->
		image = Images.findOne({image_id: id}).jpeg.buffer
		return image.toString('base64')
	remove_images: () ->
		Images.remove({})
	add_image: (id, body) ->
