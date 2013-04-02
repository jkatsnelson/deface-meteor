Deface
=========

Deface is a collaborative draw-on-someone's-face app.

  - Provide a link to any jpeg on the internet, and it will pop up on the screen shortly.
  - Add SVG images of cats to the photo. 
  - Use the draw tool to upgrade the photo with MS Paint optimization.

Deface was written by John Katsnelson. Check out his website to read more about him and the project: [JKats.info] [jkats].

Version
-

0.1

Tech
-----------

Deface uses:

* [Meteor] - such a fun framework!
* [Fabric] - A powerful and simple canvas library
* [Request] - Because Meteor's HTTP module didn't cut it
* [Coffeescript] - Because curly braces.
* [Twitter Bootstrap] - You know why.

Installation
--------------

1. Install Meteor
2. Pull this repo from github.
3. Run "meteor" in the command line within the project folder.
4. Check your local host, and commence defacement.

Interesting technical problems
==============================
---
Futures!
------

The server side component of this app involves one method:

    get_image: (url, id) ->
      fut = new Future()
    options =
      url: url
      encoding: null
    # Get raw JPG binaries
    request.get options, (error, result, body) ->
      if error then return console.error error
      jpeg = body.toString('base64')
      fut.ret jpeg
    # pause until binaries are fully loaded
    return fut.wait()
        

If futures are not used in this code, it implicitly returns the request object, rather than fut.wait().

To make the code block and wait for an asynchronous function to return, simply:

1) Create a Future

    fut = new Future()
2) Give the future something to return

  fut.ret jpeg
3) Return the 'wait' method where the code should block.

    fut.wait()

---
Adding Node Modules to Meteor
----
Deface uses the [Request][request] node module to grab jpg images as raw binary.
(I couldn't use Meteor's http library to do this-- it wasn't returning the correct binaries. Like a good dev, I opened a bug report.)

It's slightly tricky to add node modules to Meteor AND successfully deploy to Meteor's hosting platform.

Here is the code:

    require = __meteor_bootstrap__.require;
    fs = require('fs')
    path = require('path')
    base = path.resolve '.'
    isBundle = fs.existsSync base + '/bundle'
    modulePath = base + (if isBundle then '/bundle/static' else '/public') + '/node_modules'
    request = require(modulePath + '/request')

...So what is going on here?

Meteor provides require.js with this call to meteor bootstrap:

    require = __meteor_bootstrap__.require;

Just for getting node modules to work, require the filesystem module (fs) and path module.

    fs = require('fs')
    path = require('path')

Using Path, find the base directory of the project:

    base = path.resolve '.'

Check if the code is in production by looking for a "bundle" file

    isBundle = fs.existsSync base + '/bundle'

Based on whether the code is in production or development, create the proper path to the node modules:

    modulePath = base + (if isBundle then '/bundle/static' else '/public') + '/node_modules'

Then use the correct path to require request:

    request = require(modulePath + '/request')

---
Public Collaboration
---

Leveraging Meteor's observer helpers and [Fabric]'s event system and serialization methods makes it easy to add collaborative drawing.

Here's how:

First, add an event on mouse up that turns the entire canvas into JSON and adds it to MongoDB.

    window.canvas.on 'mouse:up', () ->
        image = window.canvas.toJSON()
        Images.insert image

Then, on start-up:

    Meteor.startup ->

Initiate a new Fabric canvas

      window.canvas = new fabric.Canvas 'c'

Create a query on the images database, and watch for the 'added' event

      query = Images.find({})
      query.observe
        added: (image) ->
          image.objects && window.canvas.loadFromJSON image

When an image is added, use fabric's 'loadFromJSON' method to put the added image in the canvas, overwriting the current canvas.

---
TODOs
---

Add rooms:

    1. Unique id on images in DB
    2. Allow users to select rooms
    3. Make observe and mouse:up events use an id parameter.

Optimize Collaboration:

    1. Change the mouse:up event to only submit the most recent change as a document in MongoDB
    2. Change the observe function to add the latest change into the canvas rather than re-writing the whole canvas.

Add more canvas drawing tools:

    1. Implement more of fabric's canvas manipulation methods.

[Fabric]: http://fabricjs.com/
[jkats]: http://jkats.info/
[Meteor]: http://meteor.com/
[coffeescript]: http://coffeescript.org/
[Twitter Bootstrap]: http://twitter.github.com/bootstrap/
[jQuery]: http://jquery.com  
[request]: https://github.com/mikeal/request
  

    