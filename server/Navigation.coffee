geohash = require("ngeohash")
_ = require("underscore")._
util = require("util")

class Navigation

  navigateFrom: (geohash, success) =>
    success({
      'down' : @_downFrom(geohash)
    })

  _downFrom: (baseGeohash) =>
    base32 = ['0','1','2','3','4','5','6','7','8','9','b','c','d','e','f','g','h','j','k','m','n','p','q','r','s','t','u','v','w','x','y','z']
    geohashes = for char in base32
      baseGeohash + char
    rows = _.chain(geohashes).groupBy((g) => geohash.decode(g).latitude).values().value()
    rows = _.map(rows, (r) => _.chain(r).sortBy((g) => geohash.decode(g).longitude).map(@_toUrl("/%s/")).value())
    {
      columns: rows[0].length
      rows: rows.length
      values: rows
    }

  _toUrl: (format) =>
    (geohash) =>
      {
        name: geohash,
        href: util.format(format, geohash)
      }


module.exports = Navigation