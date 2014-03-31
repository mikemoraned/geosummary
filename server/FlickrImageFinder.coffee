HTTP = require("q-io/http")
_ = require("underscore")._
util = require("util")
ngeohash = require("ngeohash")
Base58 = require('encdec').create()

class FlickrImageFinder
  constructor: (@apiKey, @size) ->
    @fixedURI = util.format("http://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=%s" +
    "&sort=interestingness-desc&content_type=1&media=photos&license=1,2,3,4,5,6,7" +
    "&extras=owner_name,geo" +
    "&format=json&nojsoncallback=1",
      @apiKey)

  findImages: (geohash, success, error) =>
    url =
      if geohash.length > 0
        util.format("%s&bbox=%s", @fixedURI, @_boundingBox(geohash))
      else
        @fixedURI

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
    [minlat, minlon, maxlat, maxlon] = ngeohash.decode_bbox(geohash)
    # flick expects minimum_longitude, minimum_latitude, maximum_longitude, maximum_latitude. (from
    # bbox docs at https://www.flickr.com/services/api/flickr.photos.search.html)
    [minlon, minlat, maxlon, maxlat].join(",")

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
      console.log("Num results returned: #{flickrSearchJson.photos.photo.length}")
      _.map(flickrSearchJson.photos.photo, (p) =>
        console.log("#{p.latitude} , #{p.longitude} -> #{ngeohash.encode(p.latitude, p.longitude)}")

        {
          'img_id' : p.id
          'img_href'  : util.format("http://farm%s.staticflickr.com/%s/%s_%s_%s.jpg", p.farm, p.server, p.id, p.secret, @size)
          'info_href' : util.format("http://flic.kr/p/%s", Base58.encode(p.id))
          'geohash' : ngeohash.encode(p.latitude, p.longitude)
          'name' : p.title
          'authority' : {
            'name' : p.ownername
            'href' : util.format("http://flickr.com/photos/%s", p.owner)
          }
        }
      )
    else
      {}

module.exports = FlickrImageFinder
