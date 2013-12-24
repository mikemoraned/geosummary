HTTP = require("q-io/http")
_ = require("underscore")._
util = require("util")

class FlickrImageFinder
  constructor: (@apiKey, @size) ->

  findImages: (success, error) =>
    url = util.format("http://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=%s&bbox=50%2C12%2C51%2C13&format=json&nojsoncallback=1", @apiKey)
    HTTP.request(url).then(
      (result) =>
        console.log("Status: %s", result.status)
        if result.status == 200
          @_parseResponse(result.body, success, error)
        else
          error()
      , error)

  _parseResponse: (io, success, error) =>
    console.log("Will parse response")
    io.read().then(
      (s) => success(@_convertToImageResult(JSON.parse(s)))
      ,
      error
    )

  _convertToImageResult: (flickrSearchJson) =>
    # format: http://farm{farm-id}.staticflickr.com/{server-id}/{id}_{secret}_[mstzb].jpg
    # (see http://www.flickr.com/services/api/misc.urls.html)

    _.map(flickrSearchJson.photos.photo, (p) =>
      {
        href: util.format("http://farm%s.staticflickr.com/%s/%s_%s_%s.jpg", p.farm, p.server, p.id, p.secret, @size)
      }
    )

module.exports = FlickrImageFinder
