require = __meteor_bootstrap__.require
fs = require("fs")
Meteor.methods
	pull_image: (url) ->
		id = url.split('/').pop()
		Images.insert({id: id})
		Meteor.http.call "GET", url,(err, res) ->
			Images.update {id: id}, {id: id, jpeg: res.content}
Meteor.Router.add '/public/:id', 'GET', (id) ->
	Images.find({id: id})