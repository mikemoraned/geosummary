class Application
  constructor: (@location) ->
    console.log("Loaded")
    console.log("using:")
    console.dir(@location)
    @model = {
      images: ko.observableArray([])
    }

  run: () =>
    $.getJSON(@location, (data, status) =>
      console.dir(data)
      console.dir(status)
      if status == "success" && data.images?
        console.dir(data.images)
        @model.images(data.images)
      else
        console.log("Failed")
    )

window.Application = Application