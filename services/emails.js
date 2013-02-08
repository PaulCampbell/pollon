var util = require('util'),
    jade = require('jade'),
    path = require('path');


  function renderJadeFile(template, options) {
      var fn = jade.compile(template, options);
      return fn(options.locals);
}

emails = {
  send: function(template, mailOptions, templateOptions) {
    mailOptions.to = mailOptions.to;
    renderJadeFile(path.join(__dirname,'..', 'views', 'mailer', template), templateOptions, function(err, text) {
      // Add the rendered Jade template to the mailOptions
      mailOptions.body = text;

      // Merge the app's mail options
      var keys = Object.keys(app.set('mailOptions')),
          k;
      for (var i = 0, len = keys.length; i < len; i++) {
        k = keys[i];
        if (!mailOptions.hasOwnProperty(k))
          mailOptions[k] = app.set('mailOptions')[k]
      }

      console.log('[SENDING MAIL]', util.inspect(mailOptions));

      // Only send mails in production
      if (app.settings.env == 'production') {
        mailer.send(mailOptions,
          function(err, result) {
            if (err) {
              console.log(err);
            }
          }
        );
      }
    });
  },

  sendWelcome: function(user) {
    this.send('welcome.jade', { to: user.email, subject: 'Welcome' }, { locals: { user: user } });
  },

  sendPasswordReset: function(user, passwordReset) {
    this.send('passwordreset.jade', { to: user.email, subject: 'Welcome' }, { locals: { user: user, passwordReset: passwordReset } });
  }

};


exports.send = emails.send;
exports.sendWelcome = emails.sendWelcome;
exports.sendPasswordReset= emails.sendPasswordReset;