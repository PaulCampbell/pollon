var mongoose = require('mongoose');
var Schema = mongoose.Schema;
var ObjectId = Schema.ObjectId;

var PasswordResetSchema = new Schema({
        requested: {type:Date, default: Date.now},
        user: { type: Schema.Types.ObjectId , ref: 'User'},
        fullfilled: { type: Boolean, default: false},
        token: { type:String }
});

PasswordResetSchema.virtual('isValid').get(function(){
   var cutOffDate = new Date();
   cutOffDate.setDate(new Date().getDate()-1)
   return (this.requested > cutOffDate) && this.fullfilled == false;
});

PasswordResetSchema.virtual('id')
   .get(function() {
     return this._id.toHexString();
   });

PasswordResetSchema.pre('save', function(next) {
    if(this.isNew){
       this.token = this.id;
    }
    return next();
 });


exports.PasswordReset = mongoose.model('PasswordReset', PasswordResetSchema)