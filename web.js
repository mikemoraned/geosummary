// Generated by CoffeeScript 1.6.3
(function() {
  var FlickrImageFinder, app, express, imageFinder, logfmt, port, thisPackage,
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

  thisPackage = require("./package.json");

  app.get('/', function(req, resp) {
    return resp.send("<!doctype html>\n<html lang=en>\n<meta charset=utf-8>\n<h1>GeoSummary version " + thisPackage.version + "</h1>\nFor info, see: <a href=\"https://github.com/mikemoraned/geosummary\">geosummary</a> on github.");
  });

  FlickrImageFinder = require("./server/FlickrImageFinder");

  imageFinder = new FlickrImageFinder("0c147ab9170b0e96b3aea305f28695a5", "c");

  app.get('/images/:geohash', function(req, resp) {
    var _this = this;
    return imageFinder.findImages(function(result) {
      console.dir(result);
      return resp.send({
        'geohash': req.params.geohash,
        'result': result
      });
    }, function() {
      return resp.sendStatus(404);
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
