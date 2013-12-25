class Application
  constructor: (@baseURI, @location, @limit) ->
    console.log("Loaded")
    console.log("using: base: %s, location: %s, limit: %s", @baseURI, @location, @limit)
    @model = {
      images: ko.observableArray([])
    }

  run: () =>
    uri = URI(@location).absoluteTo(@baseURI).toString()
    console.log("Fetching: %s", uri)
    $.getJSON(uri, (data, status) =>
      console.dir(data)
      console.dir(status)
      if status == "success" && data.images?
        console.dir(data.images)
        @model.images(_.first(data.images, @limit))
      else
        console.log("Failed")
    )

window.Application = Application