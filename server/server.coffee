require = __meteor_bootstrap__.require
fs = require("fs")
httpGet = require('http-get')
Meteor.methods
	pull_image: (url) ->
		id = url.split('/').pop()
		Images.insert({image_id: id})
		httpGet url, 'image.jpeg', (err, res) ->
			if error console.error error
			else console.log "file downloaded at: " + result.file
Meteor.Router.add '/public/:id', 'GET', (id) ->
	img = Images.findOne({image_id: id}).jpeg
	console.log img
	return [200, {'Content-Type' : 'image/jpeg'}, img]