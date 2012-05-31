mongoose = require 'mongoose'
Schema   = mongoose.Schema
ObjectId = Schema.ObjectId

Nonogram = new Schema {
    title:   {type: String, validate: /^(?!\s*$).+/}
    size:    {type: Number, min: 5, max: 20} 
    data:    String, 
    author:  String, 
    level:   {type: Number, default: 1}
    random:  {type: String, default: Math.random()}
    created: {type: Date, default: Date.now()} 
}, {collection : 'nonograms'}

  # , date: 
  #     type: Date,
  #     default: Date.now
  # , author: 
  #     type: String, 
  #     default: 'Anon'

module.exports = mongoose.model 'Nonogram', Nonogram