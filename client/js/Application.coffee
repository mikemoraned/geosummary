class Application
  constructor: (locations) ->
    console.log("Loaded")
    console.log("using:")
    console.dir(locations)

  run: () =>


window.Application = Application