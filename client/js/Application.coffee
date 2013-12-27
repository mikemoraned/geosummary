class Application
  constructor: (@doc, @baseURI, @imagesPath, @navigationPath, @limit) ->
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
        @_preRender()
      else
        console.log("Failed to fetch: %s", uri)
    )

  _preRender: () =>
    for row in @model.navigation().descend.values()
      for nav in row  
        @_addPreRender(nav.href())

  _addPreRender: (href) =>
    console.log("Prerender hint: %s", href)
    elem = @doc.createElement("link")
    elem.setAttribute("rel", "prerender")
    elem.setAttribute("href", href)
    @doc.getElementsByTagName("head")[0].appendChild(elem)

window.Application = Application