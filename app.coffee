express  = require "express"
mongoose = require "mongoose"
routes   = require "./routes"
app = module.exports = express.createServer()

# connect to Mongo when the app initializes
mongoose.connect 'mongodb://localhost/project_n'

mongoose.connection.on "open", ->
  console.log "mongodb is connected!!"


app.configure ->
  app.set "views", __dirname + "/views"
  app.set "view engine", "jade"
  app.use express.bodyParser()
  app.use express.methodOverride()
  app.use require("stylus").middleware(src: __dirname + "/public")
  app.use express.static(__dirname + "/public")
  app.use require('connect-assets')()
  # Order in here IS relevant
  # To the 404 route to work, the router must be set up
  # after static and connect-assets
  app.use app.router

app.configure "development", ->
  app.use express.errorHandler(
    dumpExceptions: true
    showStack: true
  )

app.configure "production", ->
  app.use express.errorHandler()

# Routes
app.get    '/',           routes.index
app.get    '/list',       routes.list
app.get    '/new',        routes.new
app.get    '/edit/:id',   routes.edit
app.get    '/random',     routes.random
app.post   '/save',       routes.save
app.delete '/delete/:id', routes.delete
# The 404 Route (ALWAYS Keep this as the last route)
app.get    '*', (req, res) ->
  res.send 'what???', 404


app.listen 3000, ->
  console.log "Express server listening on port %d in %s mode", app.address().port, app.settings.env
