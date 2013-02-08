should = require 'should'
zombie = require 'zombie'
Users = require '../Models/User.js'
PasswordResets = require '../Models/PasswordReset.js'

mongoose = require 'mongoose'

mongoose.connect 'mongodb://localhost/seeed_test'
user = null

before  (done) ->
  user = new Users.User ({ username: "jimbob", email: "jimbob@southwest.us", password: "banjo" })
  user.save (err) ->
    if err
      console.log err
    done()

after  (done) ->
  Users.User.remove (err) ->
    if err
      console.log err
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
      zombie.visit 'http://localhost:2999/', {debug: true},(e, browser)  ->
        browser.fill('input[name="email"]', 'jimbob@southwest.us').fill('input[name="password"]', 'banjo').
        pressButton '#login', ->
          console.log(browser.queryAll('.text-error').length)
          browser.queryAll('#logout').length.should.equal 1
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

    describe 'password field validation', ->

      it 'should be present', (done) ->
        zombie.visit 'http://localhost:2999/register', (e, browser) ->
          browser.fill('input[name="user[email]"]', 'email@email.com').fill('input[name="user[username]"]', 'Jahova').pressButton '#register', ->
            browser.text('.text-error[for="user[password]"]').should.equal 'required'
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

    it 'should redirect to home if the token is non existent', (done) ->
      zombie.visit 'http://localhost:2999/change-password/stupidguid', (e, browser) ->
        browser.location.pathname.should.equal '/'
        browser.text('#flash').should.equal 'Password reset link invalid'
        done()

    it 'should redirect to home if the token is expired', (done) ->
      two_days_ago = new Date()
      two_days_ago.setDate(new Date().getDate()-2)
      password_reset = new PasswordResets.PasswordReset({user:user._id, requested: two_days_ago});
      password_reset.save (err) ->
        if err
          console.log(err)
        zombie.visit 'http://localhost:2999/change-password/' + password_reset.token, (e, browser) ->
          console.log(browser.text('#flash'))
          browser.location.pathname.should.equal '/'
          browser.text('#flash').should.equal 'Password reset link expired'
          done()