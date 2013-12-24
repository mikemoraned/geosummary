// Generated by CoffeeScript 1.6.3
(function() {
  var app, express, logfmt, port,
    _this = this;

  express = require("express");

  logfmt = require("logfmt");

  app = express();

  app.use(logfmt.requestLogger());

  app.get('/', function(req, res) {
    return res.send('Hello World!');
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
