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
      boundsRect.addTo(@map)

window.MapBackground = MapBackground