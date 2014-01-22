// Generated by CoffeeScript 1.6.3
(function() {
  var FlickrImageFinder, Navigation, app, consolidate, express, geohashFromRequest, handleImages, handleNav, imageFinder, logfmt, maxCrawlDepth, navigation, port,
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

  geohashFromRequest = function(req) {
    if (req.params.geohash != null) {
      return req.params.geohash;
    } else {
      return "";
    }
  };

  Navigation = require("./server/Navigation");

  navigation = new Navigation();

  handleNav = function(req, resp) {
    var geohash,
      _this = this;
    geohash = geohashFromRequest(req);
    return navigation.navigateFrom(geohash, function(result) {
      console.dir(result);
      return resp.send({
        'geohash': geohash,
        'navigation': result
      });
    });
  };

  app.get('/navigation', handleNav);

  app.get('/:geohash/navigation', handleNav);

  FlickrImageFinder = require("./server/FlickrImageFinder");

  imageFinder = new FlickrImageFinder(process.env['FLICKR_API_KEY'], "s");

  handleImages = function(req, resp) {
    var geohash,
      _this = this;
    geohash = geohashFromRequest(req);
    return imageFinder.findImages(geohash, function(result) {
      var secondsExpiry;
      console.dir(result);
      secondsExpiry = 24 * 60 * 60;
      resp.setHeader("Cache-Control", "public, max-age=" + secondsExpiry);
      resp.setHeader("Expires", new Date(Date.now() + (secondsExpiry * 1000)).toUTCString());
      return resp.send({
        'geohash': geohash,
        'images': result
      });
    }, function() {
      console.log("Error");
      return resp.sendStatus(404);
    });
  };

  app.get('/images', handleImages);

  app.get('/:geohash/images', handleImages);

  app.get('/:geohash', function(req, resp) {
    return resp.render("geohash", {
      thisPackage: require("./package.json")
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
