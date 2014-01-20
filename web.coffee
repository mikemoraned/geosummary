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

maxCrawlDepth = 4
app.get('/:geohash/crawl', (req, resp) ->
  geohash = req.params.geohash
  hashesBelow =
    if geohash.length <= maxCrawlDepth
      navigation.hashesBelow(geohash)
    else
      []
  resp.render("crawl", {
    thisPackage: require("./package.json")
    hashesBelow: hashesBelow
  })
)

app.get('/crawl', (req, resp) ->
  resp.render("crawl", {
    thisPackage: require("./package.json")
    hashesBelow: navigation.hashesBelow("")
  })
)

# geo-hash page
app.get('/:geohash', (req, resp) ->
  resp.render("geohash", {
    thisPackage: require("./package.json")
  })
)

FlickrImageFinder = require("./server/FlickrImageFinder")
imageFinder = new FlickrImageFinder(process.env['FLICKR_API_KEY'], "s")

app.get('/:geohash/images', (req, resp) ->
  imageFinder.findImages(req.params.geohash,
    (result) =>
      console.dir(result)
      secondsExpiry = 24 * 60 * 60
      resp.setHeader "Cache-Control", "public, max-age=#{secondsExpiry}"
      resp.setHeader "Expires", new Date(Date.now() + (secondsExpiry * 1000)).toUTCString()
      resp.send({
        'geohash' : req.params.geohash,
        'images' : result
      })
    ,
    () ->
      console.log("Error")
      resp.sendStatus(404)
  )
)

Navigation = require("./server/Navigation")
navigation = new Navigation()

app.get('/:geohash/navigation', (req, resp) ->
  navigation.navigateFrom(req.params.geohash,
    (result) =>
      console.dir(result)
      resp.send({
        'geohash' : req.params.geohash,
        'navigation' : result
      })
  )
)



port = process.env.PORT || 9000
console.log("Attempting to listen on %s ...", port)
app.listen(port, () =>
  console.log("Listening on " + port)
)