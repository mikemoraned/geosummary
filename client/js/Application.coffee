class Application
  constructor: (@baseURI, @imagesPath, @navigationPath, @limit) ->
    console.log("Loaded")
    console.log("using: base: %s, imagesPath: %s, navigationPath: %s, limit: %s",
      @baseURI, @imagesPath, @navigationPath, @limit)
    @model = {
      navigation: ko.observable(null)
      images: ko.observableArray([])
    }

  run: () =>
    @_fetchImages()
    @_fetchNavigation()

  _fetchImages: () =>
    uri = URI(@imagesPath).absoluteTo(@baseURI).toString()
    console.log("Fetching: %s", uri)
    $.getJSON(uri, (data, status) =>
      console.dir(data)
      console.dir(status)
      if status == "success" && data.images?
        console.dir(data.images)
        @model.images(_.first(data.images, @limit))
        for image in @model.images()
          image.descend = ko.observable(null)
#        @_assignGeoLinks()
      else
        console.log("Failed to fetch: %s", uri)
    )

  _fetchNavigation: () =>
    uri = URI(@navigationPath).absoluteTo(@baseURI).toString()
    console.log("Fetching: %s", uri)
    $.getJSON(uri, (data, status) =>
      console.dir(data)
      console.dir(status)
      if status == "success" && data.navigation?
        console.dir(data.navigation)
        @model.navigation(ko.mapping.fromJS(data.navigation))
#        @_assignGeoLinks()
      else
        console.log("Failed to fetch: %s", uri)
    )

  _assignGeoLinks: () =>
    if @model.images()? and @model.navigation()?
      console.log("Assigning geo links")
      entries = @_navEntryForURL()
      console.dir(entries)
      for image in @model.images()
        console.log("Image: %s", image.img_href)
        for href in image.geo_hrefs
          console.log("Looking for %s", href)
          if entries[href]?
            console.log("Assigning %s to %s", entries[href], href)
            image.descend(entries[href])

  _navEntryForURL: () =>
    navForURL = {}
    for row in @model.navigation().descend.values()
      for entry in row
        navForURL[entry.href()] = entry
    navForURL


window.Application = Application