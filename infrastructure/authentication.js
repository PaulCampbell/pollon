

function checkAuth(req, res, next) {
  if (!req.session.user_id) {
    req.flash('error', 'You must be logged in for requested action.');
    res.redirect('/');
  } else {
    next();
  }
}

exports.checkAuth = checkAuth;