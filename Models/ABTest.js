var mongoose = require('mongoose');
var Schema = mongoose.Schema;


var ABTestSchema = new Schema({
  name: {
      type: String,
      required:true
  },

  page_a: {
        type: String,
        required:true
  },
  page_b: {
        type: String,
        required:true
  },

  user: { type: Schema.Types.ObjectId , ref: 'User'}


});


exports.ABTest = mongoose.model('ABTest', ABTestSchema)