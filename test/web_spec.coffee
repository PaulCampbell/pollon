should = require 'should'
zombie = require 'zombie'
Users = require '../Models/User.js'
PasswordResets = require '../Models/PasswordReset.js'

mongoose = require 'mongoose'

mongoose.connect 'mongodb://localhost/vocab_dev'
user = null

before  (done) ->
  user = new Users.User ({ username: "jimbob", email: "jimbob@southwest.us", password: "banjo1" })
  user.save (err) ->
    if err
      console.log err
    done()

after  (done) ->
  Users.User.remove {username: "jimbob"}, (err) ->
    Users.User.remove {username: "jimmyabob2"}, (err) ->
      done()

describe 'Web tests', ->

  describe 'log in', ->
    it 'should return error when no email or password entered', (done) ->
      zombie.visit 'http://localhost:2999/',(e, browser)  ->
        browser.pressButton '#login', ->
          browser.text('#flash').should.equal 'Email or password incorrect'
          done()

    it 'should return error when incorrect email or password entered', (done) ->
          zombie.visit 'http://localhost:2999/',(e, browser)  ->
            browser.fill('input[name="email"]', 'noone@email.com').fill('input[name="password"]', 'XXX').
            pressButton '#login', ->
              browser.text('#flash').should.equal 'Email or password incorrect'
              done()

    it 'should not display log out link when not logged in', (done) ->
      zombie.visit 'http://localhost:2999/',(e, browser)  ->
        browser.queryAll('#logout').length.should.equal 0
        done()

    it 'should display log out link once logged in', (done) ->
      zombie.visit 'http://localhost:2999/', (e, browser)  ->
        browser.fill('input[name="email"]', 'jimbob@southwest.us').fill('input[name="password"]', 'banjo1').
        pressButton '#login', ->
          browser.queryAll('#logout').length.should.equal 1
          done()

  describe 'log out', ->
    browser = null
    before (done) ->
      zombie.visit 'http://localhost:2999/', (e, brws)  ->
        brws.fill('input[name="email"]', 'jimbob@southwest.us').fill('input[name="password"]', 'banjo1').
        pressButton '#login', ->
          browser = brws
          done()

    it 'should log the user out', (done) ->
      browser.visit 'http://localhost:2999/logout', (e, browser)  ->
        browser.text('h2').should.equal 'Log in'
        done()

  describe 'user registration', ->

    it 'should have no error lables when it first loads', (done) ->
      zombie.visit 'http://localhost:2999/register', (e, browser) ->
        browser.queryAll('.text-error').length.should.equal 0
        done()

    it 'should have error labels when submitted with invalid data', (done) ->
      zombie.visit 'http://localhost:2999/register', (e, browser) ->
        browser.pressButton '#register', ->
          browser.queryAll('.text-error').length.should.greaterThan 0
          done()

    it 'should log you in once youve registered', (done)->
        zombie.visit 'http://localhost:2999/register',  (e, browser) ->
          browser.fill('input[name="user[username]"]', 'jimmyabob2').
          fill('input[name="user[email]"]', 'jimbob2@southwest.us').
          fill('input[name="user[password]"]', 'password').pressButton '#register', ->
            browser.queryAll('#logout').length.should.equal 1
            done()

    describe 'password field validation', ->

      it 'should be present', (done) ->
        zombie.visit 'http://localhost:2999/register', (e, browser) ->
          browser.fill('input[name="user[email]"]', 'email@email.com').fill('input[name="user[username]"]', 'Jahova').
          pressButton '#register', ->
            browser.text('.text-error[for="user[password]"]').should.equal 'required'
            done()

      it 'should be more than 5 characters long', (done) ->
        zombie.visit 'http://localhost:2999/register', (e, browser) ->
          browser.fill('input[name="user[email]"]', 'email@email.com').fill('input[name="user[username]"]', 'Jahova').
          fill('input[name="user[password]"]', 'short').pressButton '#register', ->
            browser.text('.text-error[for="user[password]"]').should.equal 'Must be more than 5 characters'
            done()



    describe 'email field validation', ->

      it 'should be present', (done) ->
        zombie.visit 'http://localhost:2999/register', (e, browser) ->
          browser.pressButton '#register', ->
            browser.text('.text-error[for="user[email]"]').should.equal 'required'
            done()

      it 'should be valid email format', (done) ->
        zombie.visit 'http://localhost:2999/register', (e, browser) ->
          browser.fill('input[name="user[email]"]', 'notanemail').pressButton '#register', ->
            browser.text('.text-error[for="user[email]"]').should.equal 'Must be valid email address'
            done()

      it 'should be unique', (done) ->
            zombie.visit 'http://localhost:2999/register', (e, browser) ->
              browser.fill('input[name="user[username]"]', 'jimmyabob').
              fill('input[name="user[email]"]', 'jimbob@southwest.us').
              fill('input[name="user[password]"]', 'password').pressButton '#register', ->
                browser.text('.text-error[for="user[email]"]').should.equal 'Email already in use'
                done()

    describe 'username field validation', ->

      it 'should be unique', (done) ->
        zombie.visit 'http://localhost:2999/register', (e, browser) ->
          browser.fill('input[name="user[username]"]', 'jimbob').
          fill('input[name="user[email]"]', 'email@email.com').
          fill('input[name="user[password]"]', 'password').pressButton '#register', ->
            browser.text('.text-error[for="user[username]"]').should.equal 'Username already in use'
            done()

      it 'should be present', (done) ->
       zombie.visit 'http://localhost:2999/register', (e, browser) ->
         browser.pressButton '#register', ->
           browser.text('.text-error[for="user[username]"]').should.equal 'required'
           done()

      it 'should be more than 2 characters', (done) ->
        zombie.visit 'http://localhost:2999/register', (e, browser) ->
          browser.fill('input[name="user[username]"]', 'a').pressButton '#register', ->
            browser.text('.text-error[for="user[username]"]').should.equal 'Must be between 3 and 50 characters'
            done()


  describe 'password reset', ->

    describe 'bad token', ->
      it 'should redirect to home if the token is non existent', (done) ->
        zombie.visit 'http://localhost:2999/change-password/notanid', (e, browser) ->
          browser.location.pathname.should.equal '/'
          browser.text('#flash').should.equal 'Password reset link invalid'
          done()

      it 'should redirect to home if the token is expired', (done) ->
        two_days_ago = new Date()
        two_days_ago.setDate(new Date().getDate()-2)
        password_reset = new PasswordResets.PasswordReset({user:user._id, requested: two_days_ago});
        password_reset.save (err) ->
          zombie.visit 'http://localhost:2999/change-password/' + password_reset.token, (e, browser) ->
            browser.location.pathname.should.equal '/'
            browser.text('#flash').should.equal 'Password reset link expired'
            done()


    describe 'good token', ->

      password_reset = null
      it 'should disply the password update screen', (done) ->
        password_reset = new PasswordResets.PasswordReset({user:user._id})
        password_reset.save (err) ->
          zombie.visit 'http://localhost:2999/change-password/' + password_reset.token, (e, browser) ->
            browser.text('.css-table h2').should.equal 'Update your password'
            done()


      it 'should kick off if the submitted passwords dont match', (done) ->
        zombie.visit 'http://localhost:2999/change-password/' + password_reset.token, (e, browser) ->
          browser.fill('input[name="password"]', 'mynewpassword').fill('input[name="confirmPassword"]','nonmatchingpassword').
          pressButton '#changepassword', ->
            browser.text('#flash').should.equal 'Passwords do not match'
            done()

      it 'should kick off if the submitted password is too short', (done) ->
        zombie.visit 'http://localhost:2999/change-password/' + password_reset.token, (e, browser) ->
          browser.fill('input[name="password"]', 'qwe').fill('input[name="confirmPassword"]','qwe').
          pressButton '#changepassword', ->
            browser.text('#flash').should.equal 'Must be more than 5 characters'
            done()

      it 'should kick off if the submitted password is not present', (done) ->
              zombie.visit 'http://localhost:2999/change-password/' + password_reset.token, (e, browser) ->
                browser.fill('input[name="password"]', '').fill('input[name="confirmPassword"]','').
                pressButton '#changepassword', ->
                  browser.text('#flash').should.equal 'Password required'
                  done()

      it 'should redirect you back home if the token is not found in the db', (done) ->
        zombie.visit 'http://localhost:2999/change-password/' + password_reset.token, (e, browser) ->
          browser.fill('input[name="password"]', 'mynewpassword').fill('input[name="confirmPassword"]','mynewpassword').
          fill('input[name="token"]', 'asdasd').pressButton '#changepassword', ->
            browser.text('#flash').should.equal 'Password reset link invalid'
            done()

      it 'should update the password if the passwords match and token is valid', (done) ->
        zombie.visit 'http://localhost:2999/change-password/' + password_reset.token, (e, browser) ->
          browser.fill('input[name="password"]', 'mynewpassword').fill('input[name="confirmPassword"]','mynewpassword').
          pressButton '#changepassword', ->
            browser.text('#flash').should.equal 'Password changed. Hopefully you can log in now.'
            done()


  describe 'edit account', ->
    describe 'form page', ->
      describe 'annonymous', ->
        it 'should redirect annonymous user to home page', (done) ->
          zombie.visit 'http://localhost:2999/account-settings/', (e, browser) ->
            browser.location.pathname.should.equal '/'
            browser.text('#flash').should.equal 'You must be logged in for requested action.'
            done()

      describe 'logged in', ->
        browser = null
        before (done) ->
          zombie.visit 'http://localhost:2999/', (e, brwsr)  ->
            brwsr.fill('input[name="email"]', 'jimbob@southwest.us').fill('input[name="password"]', 'mynewpassword').
            pressButton '#login', ->
              browser = brwsr
              done()

        it 'should allow logged in user access', (done) ->
          browser.visit 'http://localhost:2999/account-settings/', (e, browser) ->
            browser.text('h2').should.equal 'Account settings'
            done()

        it 'form should be populated with users current details', (done) ->
          browser.visit 'http://localhost:2999/account-settings/', (e, browser) ->
            browser.queryAll('input[name="user[username]"]')[0].value.should.equal 'jimbob'
            done()

        it 'should do the whole validation thing', (done) ->
          browser.visit 'http://localhost:2999/account-settings/',{debug:true},  (e, browser) ->
            browser.fill('input[name="email"]', ' ').pressButton '#update', ->
              browser.text('.text-error[for="user[email]"]').should.equal 'required'
              done()



    describe 'reset password', ->
      browser = null
      before (done) ->
        zombie.visit 'http://localhost:2999/', (e, brwsr)  ->
          brwsr.fill('input[name="email"]', 'jimbob@southwest.us').fill('input[name="password"]', 'mynewpassword').
          pressButton '#login', ->
            browser = brwsr
            done()

      it 'should generate reset password token and redirect to reset password page', (done) ->
        browser.visit 'http://localhost:2999/account-settings/', (e, browser) ->
          browser.pressButton '#changePassword', ->
            browser.text('h2').should.equal 'Update your password'
            done()

