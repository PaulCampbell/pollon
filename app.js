var express = require('express')
  , http = require('http')
  , path = require('path')
  , mongoose = require('mongoose')
  , flash = require('connect-flash')
  , routes = require ('./infrastructure/routes.js');


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
  app.use(express.cookieParser('somekindasecret'));
  app.use(express.cookieSession('sid'));
  app.use(express.session({ secret: "lola dog",  cookie: { maxAge: 60000 }}));
  app.use(app.router);
  app.use(require('stylus').middleware(__dirname + '/public'));
  app.use(express.static(path.join(__dirname, 'public')));
  app.set('mailOptions', {
    host: 'localhost',
    port: '25',
    from: 'dw@example.com'
  });
});

app.configure('development', function(){
  app.use(express.errorHandler());
});

routes.init(app);

http.createServer(app).listen(app.get('port'), function(){
  console.log("Express server listening on port " + app.get('port'));
});
