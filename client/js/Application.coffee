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
      if status == "success" && data.result?
        console.dir(data.result)
        @model.images(data.result)
      else
        console.log("Failed")
    )

window.Application = Application