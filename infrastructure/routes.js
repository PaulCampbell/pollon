var  user = require('../actions/user')
  , home = require('../actions/home')
  , account = require('../actions/account')
  , ab_test = require('../actions/ab_test')
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
app.post('/authedPasswordChange',authentication.checkAuth, account.authedPasswordChange)
app.get('/account-settings',authentication.checkAuth, account.accountSettingsForm);
app.post('/account-settings',authentication.checkAuth, account.accountSettings);

app.get('/tests/new', authentication.checkAuth, ab_test.addTestForm)
app.post('/tests', authentication.checkAuth, ab_test.addTest)
}

exports.init = init;