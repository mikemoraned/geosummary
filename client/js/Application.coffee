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
      else
        console.log("Failed to fetch: %s", uri)
    )

window.Application = Application