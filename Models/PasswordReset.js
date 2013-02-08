var mongoose = require('mongoose');
var Schema = mongoose.Schema;
var ObjectId = Schema.ObjectId;

var PasswordResetSchema = new Schema({
        requested: {type:Date, default: Date.now},
        token: {
            type: String,
            unique: true
        },
        user: { type: Schema.Types.ObjectId , ref: 'User'}
});

PasswordResetSchema.virtual('isValid').get(function(){
   var cutOffDate = new Date();
   cutOffDate.setDate(new Date().getDate()-1)
   return this.requested > cutOffDate;
});


PasswordResetSchema.pre('save', function(next) {
    this.token = guid();
    return next();
 });

function s4() {
  return Math.floor((1 + Math.random()) * 0x10000)
             .toString(16)
             .substring(1);
};

function guid() {
  return s4() + s4() + '-' + s4() + '-' + s4() + '-' +
         s4() + '-' + s4() + s4() + s4();
}

exports.PasswordReset = mongoose.model('PasswordReset', PasswordResetSchema)