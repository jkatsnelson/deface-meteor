require = __meteor_bootstrap__.require;
fs = require('fs')
path = require('path')
base = path.resolve '.'
isBundle = fs.existsSync base + '/bundle'
modulePath = base + (if isBundle then '/bundle/static' else '/public') + '/node_modules'
request = require(modulePath + '/request')

Meteor.methods
	get_image: (url, id) ->
		console.log url
		query = Images.find success: id
		no_image = _.isEmpty query.fetch()
		if no_image is true
			options =
				url: url
				encoding: null
			request.get options, (error, result, body) ->
				if error then return console.error error
				jpeg = body.toString('base64')
				console.log 'made a get request'
				Fiber ->
					Images.insert {image_id: id, jpeg: jpeg}, (err, nastyid) ->
						Images.insert {success: id}
				.run()
		else console.log "image already exists"
	remove_images: () ->
		console.log 'eraseyrasey'
		Images.remove({})