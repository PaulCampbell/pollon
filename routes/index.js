var Users = require('../Models/User.js');
var flash = require('connect-flash');
var Emails = require ('../services/emails.js')
var PasswordResets = require ('../Models/PasswordReset.js')


exports.index = function(req, res){
  res.render('index', {
      title: 'Express',
      username: req.session.user_id,
      flashmsg: req.flash('error')
  });
};


function registerForm(req, res) {
    var user = new Users.User();
    res.render('register', {
        user: user,
        title: 'Register',
        validationerrors: {}
      });
}

exports.registerForm = registerForm;

function register(req, res) {
    var user = new Users.User(req.body.user);

    function userSaveFailed(err) {
        if(err.code == 11000 && err.err.indexOf("email") != -1)
          err = {message: 'Validation failed', name: 'ValidationError',errors: {email: { type: "Email already in use"}}};
        if(err.code == 11000 && err.err.indexOf("username") != -1)
          err = {message: 'Validation failed', name: 'ValidationError',errors: {username: { type: "Username already in use"}}};
        if(err.type=="noPassword")
          err = {message: 'Validation failed', name: 'ValidationError',errors: {password: { type: "required"}}};
        if(err.type=="shortPassword")
          err = {message: 'Validation failed', name: 'ValidationError',errors: {password: { type: "Must be more than 5 characters"}}};

        req.flash('error', 'Account creation failed');
        res.render('register.jade', {
           title: 'register',
            user: user,
            flashmsg: req.flash('error'),
            validationerrors: err.errors
        });
    }

    user.save(function(err) {
        if (err) return userSaveFailed(err);
        req.flash('info', 'Your account has been created');
        Emails.sendWelcome(user);
        req.session.user_id = user.id;
        res.redirect('/');
    });
}

exports.register = register;


function login (req, res) {
    var post = req.body;

    function loginFailed(){
       req.flash('error', 'Email or password incorrect');
       res.render('index', {
           flashmsg: req.flash('error'),
           title: 'Express'
       });
    }
    Users.User.findOne({email: post.email}, function (err, user) {
       if (err || !user) {
           return loginFailed();
       } else {
           if(user.authenticate(post.password))
           {
               req.session.user_id = user.username;
               res.redirect('/');
           }
           else
           {
             return loginFailed();
           }
       }
    });
}

exports.login = login;


function logout (req, res) {
 delete req.session.user_id;
 res.redirect('/');
}

exports.logout = logout;


function forgottenPassword (req, res) {
    res.render('forgottenpassword', {
              title: "Forgotten password"
          });
        }

exports.forgottenPassword = forgottenPassword


function passwordRequest(req,res) {
    var post = req.body;
    var passwordResetToken = '';
    Users.User.findOne( { email: post.email }, function(err, user){
        if(err)
            console.log('invalid email')
        else {
            var passwordReset = new PasswordResets.PasswordReset( { user: user._id})
            passwordReset.save(function(err){
                if(err)  console.log('error doing a password reset: ' + err)
                Emails.sendPasswordReset(user, passwordReset);
                passwordResetToken = passwordReset.token;
                console.log('password reset with token: ' + passwordReset.token + 'generated for user ' + user.username)
            })
        }

        res.render('passwordreset', {
            title: "Password reset requested"
        });
    });
}

exports.passwordRequest = passwordRequest


function changePassword(req,res) {

    function invalidToken(err) {
        req.flash('error', err);
        res.redirect('/');
    }

    var postedtoken =  req.params.token;
    PasswordResets.PasswordReset.findOne( {token: postedtoken}, function(err, model){
        if(!model)
          return invalidToken('Password reset link invalid');
        else if (!model.isValid)
          return invalidToken('Password reset link expired');
        else {
          console.log('password reset valid!')
          res.render('changepassword', {
            title: "Update your password",
            passwordResetToken:postedtoken
          });
        }
    })
}

exports.changePassword = changePassword;


function changePasswordRequest(req,res) {

    var postedToken = req.body.token

    function requestFailed(msg, token){
           req.flash('error', msg);
           res.render('changepassword', {
               flashmsg: req.flash('error'),
               title: "Update your password",
               passwordResetToken:token
           });
        }

    if(req.body.password !== req.body.confirmPassword) {
        return requestFailed("Passwords do not match", postedToken);
    }
}

exports.changePasswordRequest = changePasswordRequest;
