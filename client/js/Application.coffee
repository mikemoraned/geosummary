class Application
  constructor: (@baseURI, @imagesPath, @navigationPath, @limit, @perGeoHashLimit) ->
    console.log("Loaded")
    console.log("using: base: %s, imagesPath: %s, navigationPath: %s, limit: %s",
      @baseURI, @imagesPath, @navigationPath, @limit)
    @model = {
      navigation: ko.observable(null)
      images: ko.observableArray([])
    }
    @model.navigation.subscribe(@_assignImagesToNavigation)
    @model.images.subscribe(@_assignImagesToNavigation)
    @usedImgIds = {}

  run: () =>
    @_fetchImages(true)
    @_fetchNavigation()

  _assignImagesToNavigation: () =>
    console.log("Assigning")
    if @model.images().length > 0 and @model.navigation()?
      console.log("We have some #{@model.images().length} images and navigation")
      for rows in @model.navigation().descend.values()
        for value in rows
          value.loaded(true)
          value.images(_.chain(@model.images())
            .filter((image) =>
              image.geohash.indexOf(value.name()) == 0
            )
            .take(@perGeoHashLimit)
            .value())

  _fetchImages: (fetchRelated = false, imagesPath = @imagesPath) =>
    uri = URI(imagesPath).absoluteTo(@baseURI).toString()
    console.log("Fetching: %s", uri)
    $.getJSON(uri, (data, status) =>
      console.dir(data)
      console.dir(status)
      if status == "success" && data.images?
        console.log("Fetched: %s", uri)
        console.dir(data.images)
        current = @model.images()
        unique = @_uniqueImages(data.images)
        console.log("Unique:")
        console.dir(unique)
        expanded =
          if unique.length > 0
            _.first(current.concat(unique), @limit)
          else
            current
        @_recordUsed(unique)
        @model.images(expanded)
        if fetchRelated && data.related?
          console.log("Fetching related")
          for related in data.related
            @_fetchImages(false, related.href)
          @_fetchImages(false, data.related[0].href)
      else
        console.log("Failed to fetch: %s", uri)
    )

  _uniqueImages: (images) =>
    if images? and images.length > 0
#      images
      _.filter(images, (i) => not (@usedImgIds[i.img_id]))
    else
      []

  _recordUsed: (images) =>
    for image in images
      if image.img_id?
        @usedImgIds[image.img_id] = true

  _fetchNavigation: () =>
    uri = URI(@navigationPath).absoluteTo(@baseURI).toString()
    console.log("Fetching: %s", uri)
    $.getJSON(uri, (data, status) =>
      console.dir(data)
      console.dir(status)
      if status == "success" && data.navigation?
        console.dir("Loaded navigation")
        mapped = ko.mapping.fromJS(data.navigation)
        for rows in mapped.descend.values()
          for value in rows
            value.images = ko.observableArray([])
            value.loaded = ko.observable(false)
        @model.navigation(mapped)
      else
        console.log("Failed to fetch: %s", uri)
    )

window.Application = Application