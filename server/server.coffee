require = __meteor_bootstrap__.require
fs = require("fs")
Meteor.methods
	pull_image: (url) ->
		Meteor.http.call "GET", url,(err, res) ->
			fs.writeFile 'public/image.jpg', res.content, (err) ->
				if err then throw err
				console.log 'It\'s saved!'