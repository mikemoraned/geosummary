HTTP = require("q-io/http")

class FlickrImageFinder
  findImages: (success, error) =>
    url = "http://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=0c147ab9170b0e96b3aea305f28695a5&bbox=50%2C12%2C51%2C13&format=json&nojsoncallback=1"
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
      (s) => success(JSON.parse(s))
      ,
      error
    )

module.exports = FlickrImageFinder
