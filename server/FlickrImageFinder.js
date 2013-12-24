// Generated by CoffeeScript 1.6.3
(function() {
  var FlickrImageFinder, HTTP, util, _,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  HTTP = require("q-io/http");

  _ = require("underscore")._;

  util = require("util");

  FlickrImageFinder = (function() {
    function FlickrImageFinder(apiKey, size) {
      this.apiKey = apiKey;
      this.size = size;
      this._convertToImageResult = __bind(this._convertToImageResult, this);
      this._parseResponse = __bind(this._parseResponse, this);
      this.findImages = __bind(this.findImages, this);
    }

    FlickrImageFinder.prototype.findImages = function(success, error) {
      var url,
        _this = this;
      url = util.format("http://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=%s&bbox=50%2C12%2C51%2C13&format=json&nojsoncallback=1", this.apiKey);
      return HTTP.request(url).then(function(result) {
        console.log("Status: %s", result.status);
        if (result.status === 200) {
          return _this._parseResponse(result.body, success, error);
        } else {
          return error();
        }
      }, error);
    };

    FlickrImageFinder.prototype._parseResponse = function(io, success, error) {
      var _this = this;
      console.log("Will parse response");
      return io.read().then(function(s) {
        return success(_this._convertToImageResult(JSON.parse(s)));
      }, error);
    };

    FlickrImageFinder.prototype._convertToImageResult = function(flickrSearchJson) {
      var _this = this;
      return _.map(flickrSearchJson.photos.photo, function(p) {
        return {
          href: util.format("http://farm%s.staticflickr.com/%s/%s_%s_%s.jpg", p.farm, p.server, p.id, p.secret, _this.size)
        };
      });
    };

    return FlickrImageFinder;

  })();

  module.exports = FlickrImageFinder;

}).call(this);

/*
//@ sourceMappingURL=FlickrImageFinder.map
*/
