// Generated by CoffeeScript 1.6.3
(function() {
  var FlickrImageFinder, HTTP, ngeohash, util, _,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  HTTP = require("q-io/http");

  _ = require("underscore")._;

  util = require("util");

  ngeohash = require("ngeohash");

  FlickrImageFinder = (function() {
    function FlickrImageFinder(apiKey, size) {
      this.apiKey = apiKey;
      this.size = size;
      this._convertToImageResult = __bind(this._convertToImageResult, this);
      this._parseResponse = __bind(this._parseResponse, this);
      this._boundingBox = __bind(this._boundingBox, this);
      this.findImages = __bind(this.findImages, this);
      this.fixedURI = util.format("http://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=%s" + "&sort=interestingness-desc" + "&format=json&nojsoncallback=1", this.apiKey);
    }

    FlickrImageFinder.prototype.findImages = function(geohash, success, error) {
      var url,
        _this = this;
      console.log(geohash);
      url = util.format("%s&bbox=%s", this.fixedURI, this._boundingBox(geohash));
      console.log("url: %s", url);
      return HTTP.request(url).then(function(result) {
        console.log("Status: %s", result.status);
        if (result.status === 200) {
          return _this._parseResponse(result.body, success, error);
        } else {
          return error();
        }
      }, function(e) {
        console.log("Error in call");
        console.dir(e);
        return error();
      });
    };

    FlickrImageFinder.prototype._boundingBox = function(geohash) {
      return ngeohash.decode_bbox(geohash).join(",");
    };

    FlickrImageFinder.prototype._parseResponse = function(io, success, error) {
      var _this = this;
      console.log("Will parse response");
      return io.read().then(function(s) {
        return success(_this._convertToImageResult(JSON.parse(s)));
      }, error);
    };

    FlickrImageFinder.prototype._convertToImageResult = function(flickrSearchJson) {
      var _ref,
        _this = this;
      if (((_ref = flickrSearchJson.photos) != null ? _ref.photo : void 0) != null) {
        return _.map(flickrSearchJson.photos.photo, function(p) {
          return {
            href: util.format("http://farm%s.staticflickr.com/%s/%s_%s_%s.jpg", p.farm, p.server, p.id, p.secret, _this.size)
          };
        });
      } else {
        console.dir(flickrSearchJson);
        return {};
      }
    };

    return FlickrImageFinder;

  })();

  module.exports = FlickrImageFinder;

}).call(this);

/*
//@ sourceMappingURL=FlickrImageFinder.map
*/
