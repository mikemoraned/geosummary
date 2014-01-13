class MapBackground

  constructor: (@selector, @navigation) ->
    @map = null
    @navigation.subscribe(@_navigationChanged)

  _navigationChanged: () =>
    if @navigation()? and not @map?
      console.dir(@navigation())
      bbox = @navigation().descend.geo_bbox()
      southWest = L.latLng(bbox[0], bbox[1])
      northEast = L.latLng(bbox[2], bbox[3])
      bounds = L.latLngBounds(southWest, northEast)
      @map = L.map(@selector).fitBounds(bounds)
      L.tileLayer('http://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
        attribution: 'Map data © OpenStreetMap contributors',
        maxZoom: 18
      }).addTo(@map)
      boundsRect = L.rectangle(bounds, {color: "#ff7800", weight: 1})
#      boundsRect.addTo(@map)

      mapPixelOrigin = @map.getPixelOrigin()
      console.dir(mapPixelOrigin)
      mapPixelSize = @map.getSize()
      console.dir(mapPixelSize)

      southWestPoint = @map.project(southWest)
      northEastPoint = @map.project(northEast)
      console.dir(southWestPoint)
      console.dir(northEastPoint)

      xScale = mapPixelSize.x / (northEastPoint.x - southWestPoint.x)
      yScale = mapPixelSize.y / (southWestPoint.y - northEastPoint.y)

      console.log("xScale: #{xScale}, yScale: #{yScale}")

      $("##{@selector}").css({'-webkit-transform': "scale(#{xScale}, #{yScale})"})

window.MapBackground = MapBackground