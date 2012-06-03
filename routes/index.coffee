require '../assets/js/constants.coffee'
mongoose = require 'mongoose'
Nonogram = require '../models/nonogram.coffee'


exports.index = (req, res) ->
  res.render "index",
    title:       "Nonogram"
    scripts:     ['main.js', 'jquery-ui-1.8.20.custom.min.js']
    stylesheets: ['screen.css', 'jquery-ui-1.8.20.custom.css']

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

exports.edit = (req, res) ->
  Nonogram = mongoose.model 'Nonogram'

  Nonogram.findById req.params.id, (err, nonogram) ->
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

exports.delete = (req, res) ->
  Nonogram.findById req.params.id, (err, nonogram) ->
    nonogram.remove() if nonogram?
    res.send 'success'

exports.list = (req, res) ->
  Nonogram = mongoose.model 'Nonogram'

  Nonogram.find {}, (err, nonograms) ->
    res.render "list",
      title:       "Available nonograms"
      scripts:     ['list.js']
      stylesheets: []
      nonograms:   nonograms

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
        res.statusCode = 500
        res.send ''
      else 
        res.send req.body.id
  else
    new_nono = new Nonogram data
    new_nono.save (err) ->
      if err 
        res.statusCode = 500
        res.send ''
      else 
        res.send new_nono._id


  # nonogram.find {}, (err, nonos) ->
  #   res.send nonos

#  Nonogram.findOne {name:'prueba'}, (error, nonogram) ->
#    res.send nonogram


exports.random = (req, res) ->
  rand = Math.random()
  Nonogram.findOne {random: {$gte: rand} }, (err, nonogram) ->
    if nonogram
      res.send nonogram.data.split(',') 
    else
      Nonogram.findOne {random: {$lte: rand} }, (err, nonogram) ->
        res.send nonogram.data.split(',') 

  

  #res.send Array('555555', '555555', '555555', '555555', '555555', '-1', '-1', '-1', '-1', '-1', '-1', '-1', '-1', '-1', '-1', '-1', '-1', '-1', '-1', '-1', '555555', '555555', '555555', '555555', '555555')