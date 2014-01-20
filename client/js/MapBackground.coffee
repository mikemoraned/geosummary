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
      @map = L.map(@selector, { zoomControl:false })
      @map.fitBounds(bounds)
      L.tileLayer('http://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
        attribution: 'Map data © OpenStreetMap contributors',
        maxZoom: 18
      }).addTo(@map)

      boundsRect = L.rectangle(bounds, {color: "#ff7800", weight: 1})
      boundsRect.addTo(@map)

      @_transform(southWest, northEast)

  _transform: (southWest, northEast) =>
    console.log("Map: " + @selector)
  
    mapPixelOrigin = @map.getPixelOrigin()
    console.dir(mapPixelOrigin)
    mapPixelSize = @map.getSize()
    console.dir(mapPixelSize)
  
    southWestPoint = @map.project(southWest)
    northEastPoint = @map.project(northEast)
    console.dir(southWestPoint)
    console.dir(northEastPoint)
  
    rectTopLeft = {
      x: southWestPoint.x - mapPixelOrigin.x
      y: northEastPoint.y - mapPixelOrigin.y
    }
  
    rectSize = {
      width: northEastPoint.x - southWestPoint.x
      height: southWestPoint.y - northEastPoint.y
    }
  
    console.log("topLeft:")
    console.dir(rectTopLeft)
  
    console.log("rectSize:")
    console.dir(rectSize)

    xScale = mapPixelSize.x / rectSize.width
    yScale = mapPixelSize.y / rectSize.height
  
    xTranslate = 0
    yTranslate = 0
  
    console.log("xScale: " + xScale + ", yScale: " + yScale)
    console.log("xTranslate: " + xTranslate + ", yTranslate: " + yTranslate)

    transform = "translate(" + xTranslate + "px, " + yTranslate + "px) scale(" + xScale + ", " + yScale + ")"

    console.log(transform)

    $("#" + @selector).css({'-webkit-transform': transform})

window.MapBackground = MapBackground