require '../assets/js/constants.coffee'
mongoose = require 'mongoose'
Nonogram = require '../models/nonogram.coffee'

###
 Main game controller
###
exports.index = (req, res) ->
  res.render "index",
    title:       "Nonogram"
    scripts:     ['main.js', 'jquery-ui-1.8.20.custom.min.js']
    stylesheets: ['screen.css', 'jquery-ui-1.8.20.custom.css']

###
 Shows the create nonogram page
###
exports.new = (req, res) ->
  side = 5
  
  res.render "edit",
    title:           "New nonogram"
    scripts:         ['colorpicker.js', 'edit.js']
    stylesheets:     ['screen.css', 'colorpicker.css']
    nonogram_data:   EMPTY_CELL for num in [0...side*side]
    nonogram_id:     null
    nonogram_title:  null
    nonogram_level:  null
    nonogram_author: null
    nonogram_size:   5

###
 Shows the edit page and loads the data for a specified nonogram
###
exports.edit = (req, res) ->
  Nonogram = mongoose.model 'Nonogram'

  Nonogram.findById req.params.id, (err, nonogram) ->
    if err?
      res.send 500
    else
      res.render "edit",
        title:           "Nonogram editor"
        scripts:         ['colorpicker.js', 'edit.js']
        stylesheets:     ['screen.css', 'colorpicker.css']
        nonogram_data:   nonogram.data
        nonogram_id:     nonogram.id
        nonogram_title:  nonogram.title
        nonogram_level:  nonogram.level
        nonogram_author: nonogram.author
        nonogram_size:   nonogram.size

###
 Deletes a Nonogram from the DB
 Return 'success' ig the nonogram was succesfully removed
###
exports.delete = (req, res) ->
  Nonogram.findById req.params.id, (err, nonogram) ->
    if nonogram?
      nonogram.remove()
      # HTTP OK
      res.send 200

  # There was an error, return an HTTP 500
  res.send 500 if err?

###
 Return all nonograms stored on the DB
###
exports.list = (req, res) ->
  Nonogram = mongoose.model 'Nonogram'

  Nonogram.find {}, (err, nonograms) ->
    res.render "list",
      title:       "Available nonograms"
      scripts:     ['list.js']
      stylesheets: []
      nonograms:   nonograms

###
 Saves or updates a nonogram on the DB
 Returns its ID if it was successfully saved
###
exports.save = (req, res) ->
  Nonogram = mongoose.model 'Nonogram'

  data = 
    title:  req.body.nonogram_title
    size:   req.body.nonogram_size
    data:   req.body.nonogram_data
    author: req.body.nonogram_author
    level:  req.body.nonogram_level

  if req.body.id
    Nonogram.update {_id: req.body.id}, data, (err) ->
      if err
        console.log err 
        # HTTP Error 500
        res.send 500
      else 
        res.send req.body.id
  else
    new_nono = new Nonogram data
    new_nono.save (err) ->
      if err?
        res.send 500
      else 
        res.send new_nono._id

###
 Returns a rendomly selected nonogram from the DB
###
exports.random = (req, res) ->
  rand = Math.random()
  Nonogram.findOne {random: {$gte: rand} }, (err, nonogram) ->
    if nonogram
      res.send nonogram.data.split(',') 
    else
      Nonogram.findOne {random: {$lte: rand} }, (err, nonogram) ->
        res.send nonogram.data.split(',') 

  

  #res.send Array('555555', '555555', '555555', '555555', '555555', '-1', '-1', '-1', '-1', '-1', '-1', '-1', '-1', '-1', '-1', '-1', '-1', '-1', '-1', '-1', '555555', '555555', '555555', '555555', '555555')