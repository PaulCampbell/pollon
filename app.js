
/**
 * Module dependencies.
 */

var express = require('express')
  , user = require('./routes/user')
  , home = require('./routes/index')
  , http = require('http')
  , path = require('path')
  , mongoose = require('mongoose');
var flash = require('connect-flash');

var app = express();

// Configuration
mongoose.connect('mongodb://localhost/vocab_dev');


app.configure(function(){
    app.use(flash());
  app.set('port', process.env.PORT || 2999);
  app.set('views', __dirname + '/views');
  app.set('view engine', 'jade');
  app.use(express.favicon());
  app.use(express.logger('dev'));
  app.use(express.bodyParser());
  app.use(express.methodOverride());
  app.use(express.cookieParser('your secret here'));
  app.use(express.session());
  app.use(app.router);
  app.use(require('stylus').middleware(__dirname + '/public'));
  app.use(express.static(path.join(__dirname, 'public')));
});

app.configure('development', function(){
  app.use(express.errorHandler());
});

app.get('/', home.index);
app.get('/users', user.list);
app.get('/register', home.registerForm);
app.post('/register', home.register);
app.post('/login', home.login);
app.get('/logout', home.logout);
app.get('/forgottenpassword', home.forgottenpassword);

http.createServer(app).listen(app.get('port'), function(){
  console.log("Express server listening on port " + app.get('port'));
});
