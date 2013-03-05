var ABTests = require('../Models/ABTest.js')

function addTestForm(req, res) {
    var ab_test = new ABTests.ABTest();
    res.render('addtest', {
        ab_test: ab_test,
        title: 'Add a test',
        validationerrors: {}
      });
}

exports.addTestForm = addTestForm;


function addTest(req,res) {
  var ab_test = new ABTests.ABTest(req.body.ab_test);
  ab_test.user = req.session.user_id;

  function testCreationFailedFailed(err) {
      req.flash('error', 'Test creation failed');
      res.render('addtest.jade', {
         title: 'register',
         ab_test: ab_test,
         flashmsg: req.flash('error'),
         validationerrors: err.errors
      });
  }

  ab_test.save(function(err) {
      if (err) return testCreationFailedFailed(err);
      req.flash('info', 'AB Test created');
      res.redirect('/tests/' + ab_test._id + '/' + ab_test.name);
  });}

exports.addTest = addTest;