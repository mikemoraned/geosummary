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

# views
consolidate = require('consolidate')
app.engine('html', consolidate.mustache)
app.set('view engine', 'html')
app.set('views', __dirname + '/views')

# static, loaded client-side
app.use(express.static(__dirname + '/client'));

# home page
app.get('/', (req, resp) ->
  resp.render("index", {
    thisPackage: require("./package.json")
  })
)

FlickrImageFinder = require("./server/FlickrImageFinder")
imageFinder = new FlickrImageFinder(process.env['FLICKR_API_KEY'], "z")

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
      console.log("Error")
      resp.sendStatus(404)
  )
)

port = process.env.PORT || 9000
console.log("Attempting to listen on %s ...", port)
app.listen(port, () =>
  console.log("Listening on " + port)
)