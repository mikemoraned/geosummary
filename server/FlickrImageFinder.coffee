HTTP = require("q-io/http")
_ = require("underscore")._
util = require("util")
ngeohash = require("ngeohash")
Base58 = require('encdec').create()

class FlickrImageFinder
  constructor: (@apiKey, @size) ->
    @fixedURI = util.format("http://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=%s" +
      "&sort=interestingness-desc&content_type=1&media=photos&license=1,2,3,4,5,6,7" +
      "&format=json&nojsoncallback=1",
      @apiKey)

  findImages: (geohash, success, error) =>
    console.log(geohash)

    url = util.format("%s&bbox=%s", @fixedURI, @_boundingBox(geohash))
    console.log("url: %s", url)
    HTTP.request(url).then(
      (result) =>
        console.log("Status: %s", result.status)
        if result.status == 200
          @_parseResponse(result.body, success, error)
        else
          error()
      ,
      (e) =>
        console.log("Error in call")
        console.dir(e)
        error()
      )

  _boundingBox: (geohash) =>
    # 50%2C12%2C51%2C13
    ngeohash.decode_bbox(geohash).join(",")

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

    if flickrSearchJson.photos?.photo?
      _.map(flickrSearchJson.photos.photo, (p) =>
        {
          'img_href': util.format("http://farm%s.staticflickr.com/%s/%s_%s_%s.jpg", p.farm, p.server, p.id, p.secret, @size)
          'info_href' : util.format("http://flic.kr/p/%s", Base58.encode(p.id))
        }
      )
    else
      console.dir(flickrSearchJson)
      {}

module.exports = FlickrImageFinder
