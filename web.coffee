express = require("express")
logfmt = require("logfmt")
app = express()

app.use(logfmt.requestLogger())

# CORS to allow cross-domain access
app.all('*', (req, resp, next) ->
  resp.header("Access-Control-Allow-Origin", "*")
  resp.header("Access-Control-Allow-Headers", "X-Requested-With")
  next()
)

# inline home page
thisPackage = require("./package.json")
app.get('/', (req, resp) ->
  resp.send("""
              <!doctype html>
              <html lang=en>
              <meta charset=utf-8>
              <h1>GeoSummary version #{thisPackage.version}</h1>
              For info, see: <a href="https://github.com/mikemoraned/geosummary">geosummary</a> on github.
              """)
)

FlickrImageFinder = require("./server/FlickrImageFinder")
imageFinder = new FlickrImageFinder("0c147ab9170b0e96b3aea305f28695a5", "c")

app.get('/images/:geohash', (req, resp) ->
  imageFinder.findImages(
    (result) =>
      console.dir(result)
      resp.send({
        'geohash' : req.params.geohash,
        'result' : result
      })
    ,
    () ->
      resp.sendStatus(404)
  )
)

port = process.env.PORT || 9000
console.log("Attempting to listen on %s ...", port)
app.listen(port, () =>
  console.log("Listening on " + port)
)