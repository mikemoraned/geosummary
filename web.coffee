express = require("express")
logfmt = require("logfmt")
_ = require("underscore")._
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

# about page
app.get('/about', (req, resp) ->
  resp.render("about", {
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

geohashFromRequest = (req) ->
  if req.params.geohash?
    req.params.geohash
  else
    ""

Navigation = require("./server/Navigation")
navigation = new Navigation()

handleNav = (req, resp) ->
  geohash = geohashFromRequest(req)
  navigation.navigateFrom(geohash,
    (result) =>
      console.dir(result)
      resp.send({
        'geohash' : geohash,
        'navigation' : result
      })
    )
app.get('/navigation', handleNav)
app.get('/:geohash/navigation', handleNav)

FlickrImageFinder = require("./server/FlickrImageFinder")
imageFinder = new FlickrImageFinder(process.env['FLICKR_API_KEY'], "s")

handleImages = (req, resp) ->
  geohash = geohashFromRequest(req)
  related = _.map(navigation.hashesBelow(geohash), (below) -> {
    name: below
    href: "/#{below}/images"
  })
  imageFinder.findImages(geohash,
  (result) =>
    console.dir(result)
    secondsExpiry = 24 * 60 * 60
    resp.setHeader "Cache-Control", "public, max-age=#{secondsExpiry}"
    resp.setHeader "Expires", new Date(Date.now() + (secondsExpiry * 1000)).toUTCString()
    resp.send({
      'geohash' : geohash
      'related' : related
      'images' : result
    })
  ,
  () ->
    console.log("Error")
    resp.sendStatus(404)
  )
app.get('/images', handleImages)
app.get('/:geohash/images', handleImages)

# geo-hash page
handleGeohash = (req, resp) ->
  resp.render("geohash", {
    thisPackage: require("./package.json")
  })
app.get('/:geohash', handleGeohash)
app.get('/', handleGeohash)

port = process.env.PORT || 9000
console.log("Attempting to listen on %s ...", port)
app.listen(port, () =>
  console.log("Listening on " + port)
)