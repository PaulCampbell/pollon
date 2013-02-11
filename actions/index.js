var Users = require('../Models/User.js');
var flash = require('connect-flash');



exports.index = function(req, res){
  res.render('index', {
      title: 'Express',
      username: req.session.username,
      flashmsg: req.flash('error')
  });
};


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
           console.log('**** LOG IN ERROR ****')
           return loginFailed();
       } else {
           if(user.authenticate(post.password))
           {
               req.session.username = user.username;
               console.log(req.session.username + ' logged in')
               res.redirect('/');
           }
           else
           {
             console.log('**** LOG IN BAD PASSWORD **** ' + user.username + ' password attempted ' + post.password)
             return loginFailed();
           }
       }
    });
}

exports.login = login;


function logout (req, res) {
 delete req.session.username;
 res.redirect('/');
}

exports.logout = logout;
