express = require("express")
logfmt = require("logfmt")
app = express()

app.use(logfmt.requestLogger())

app.get('/', (req, res) =>
  res.send('Hello World!')
)

port = process.env.PORT || 9000
console.log("Attempting to listen on %s ...", port)
app.listen(port, () =>
  console.log("Listening on " + port)
)