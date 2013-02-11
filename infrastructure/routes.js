var  user = require('../actions/user')
  , home = require('../actions/index')
  , account = require('../actions/account')
  , authentication = require('./authentication.js')

function init(app){

app.get('/', home.index);
app.get('/users', user.list);
app.post('/login', home.login);
app.get('/logout', home.logout);

app.get('/register', account.registerForm);
app.post('/register', account.register);
app.get('/forgotten-password', account.forgottenPassword);
app.post('/request-password', account.passwordRequest);
app.get('/change-password/:token', account.changePassword);
app.post('/change-password', account.changePasswordRequest);
app.get('/account-settings',authentication.checkAuth, account.accountSettingsForm);
// app.get('/account-post', account.accountSettings);
}

exports.init = init;