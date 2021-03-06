geohash = require("ngeohash")
_ = require("underscore")._
util = require("util")

class Navigation

  navigateFrom: (geohash, success) =>
    nav = {
      'descend' : @_downFrom(geohash)
    }
    if geohash.length > 1
      nav.ascend = @_toUrl("/%s/")(geohash.substring(0, geohash.length - 1))
    success(nav)

  hashesBelow: (baseGeohash) =>
    base32 = ['0','1','2','3','4','5','6','7','8','9','b','c','d','e','f','g','h','j','k','m','n','p','q','r','s','t','u','v','w','x','y','z']
    for char in base32
      baseGeohash + char

  _downFrom: (baseGeohash) =>
#    base32 = ['0','1','2','3','4','5','6','7','8','9','b','c','d','e','f','g','h','j','k','m','n','p','q','r','s','t','u','v','w','x','y','z']
#    geohashes = for char in base32
#      baseGeohash + char
    geohashes = @hashesBelow(baseGeohash)
    rows = _.chain(geohashes).groupBy((g) => geohash.decode(g).latitude).values().reverse().value()
    rows = _.map(rows, (r) => _.chain(r).sortBy((g) => geohash.decode(g).longitude).map(@_toUrl("/%s/")).value())
    {
      columns: rows[0].length
      rows: rows.length
      geo_bbox: geohash.decode_bbox(baseGeohash)
      values: rows
    }

  _toUrl: (format) =>
    (geohash) =>
      {
        name: geohash,
        href: util.format(format, geohash)
      }


module.exports = Navigation