// Generated by CoffeeScript 1.6.3
(function() {
  var FlickrImageFinder, Navigation, app, consolidate, express, imageFinder, logfmt, maxCrawlDepth, navigation, port,
    _this = this;

  express = require("express");

  logfmt = require("logfmt");

  app = express();

  app.use(logfmt.requestLogger());

  app.all('*', function(req, resp, next) {
    resp.header("Access-Control-Allow-Origin", "*");
    resp.header("Access-Control-Allow-Headers", "X-Requested-With");
    return next();
  });

  consolidate = require('consolidate');

  app.engine('html', consolidate.mustache);

  app.set('view engine', 'html');

  app.set('views', __dirname + '/views');

  app.use(express["static"](__dirname + '/client'));

  app.get('/', function(req, resp) {
    return resp.render("index", {
      thisPackage: require("./package.json")
    });
  });

  maxCrawlDepth = 4;

  app.get('/:geohash/crawl', function(req, resp) {
    var geohash, hashesBelow;
    geohash = req.params.geohash;
    hashesBelow = geohash.length <= maxCrawlDepth ? navigation.hashesBelow(geohash) : [];
    return resp.render("crawl", {
      thisPackage: require("./package.json"),
      hashesBelow: hashesBelow
    });
  });

  app.get('/crawl', function(req, resp) {
    return resp.render("crawl", {
      thisPackage: require("./package.json"),
      hashesBelow: navigation.hashesBelow("")
    });
  });

  app.get('/:geohash', function(req, resp) {
    return resp.render("geohash", {
      thisPackage: require("./package.json")
    });
  });

  FlickrImageFinder = require("./server/FlickrImageFinder");

  imageFinder = new FlickrImageFinder(process.env['FLICKR_API_KEY'], "s");

  app.get('/:geohash/images', function(req, resp) {
    var _this = this;
    return imageFinder.findImages(req.params.geohash, function(result) {
      var secondsExpiry;
      console.dir(result);
      secondsExpiry = 24 * 60 * 60;
      resp.setHeader("Cache-Control", "public, max-age=" + secondsExpiry);
      resp.setHeader("Expires", new Date(Date.now() + (secondsExpiry * 1000)).toUTCString());
      return resp.send({
        'geohash': req.params.geohash,
        'images': result
      });
    }, function() {
      console.log("Error");
      return resp.sendStatus(404);
    });
  });

  Navigation = require("./server/Navigation");

  navigation = new Navigation();

  app.get('/:geohash/navigation', function(req, resp) {
    var _this = this;
    return navigation.navigateFrom(req.params.geohash, function(result) {
      console.dir(result);
      return resp.send({
        'geohash': req.params.geohash,
        'navigation': result
      });
    });
  });

  port = process.env.PORT || 9000;

  console.log("Attempting to listen on %s ...", port);

  app.listen(port, function() {
    return console.log("Listening on " + port);
  });

}).call(this);

/*
//@ sourceMappingURL=web.map
*/
