class MapBackground

  constructor: (@selector, @navigation) ->
    @map = null
    @navigation.subscribe(@_navigationChanged)

  _navigationChanged: () =>
    if not @map?
      @map = L.map(@selector).setView([51.505, -0.09], 13)
      L.tileLayer('http://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
        attribution: 'Map data © OpenStreetMap contributors',
        maxZoom: 18
      }).addTo(@map)

window.MapBackground = MapBackground