var Users = require('../Models/User.js');
var flash = require('connect-flash');

exports.index = function(req, res){
  res.render('index', { title: 'Express' });
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
        console.log(err)
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
       // Emails.sendWelcome(user);
        req.session.user_id = user.id;
        res.redirect('/');
    });
}

exports.register = register;


function login (req, res) {
    var post = req.body;

    function loginFailed(){
       req.flash('error', 'Username or password incorrect');
       res.render('index', {
           flashmsg: req.flash('error'),
           title: 'Express'
       });
    }
    Users.User.findOne({username: post.username}, function (err, user) {
       if (err || !user) {
           return loginFailed();
       } else {
           console.log(user)
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
 res.redirect('/login');
}

exports.logout = logout;
