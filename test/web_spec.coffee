should = require 'should'
zombie = require 'zombie'
Users = require '../Models/User.js'

describe 'Web tests', ->

  describe 'log in', ->
    it 'should return error when no email or password entered', (done) ->
      zombie.visit 'http://localhost:2999/',(e, browser)  ->
        browser.pressButton '#login', ->
          browser.text('#flash').should.equal 'Username or password incorrect'
          done()

  describe 'Register', ->
    before  (done) ->
      user = new Users.User { username: "jimbob", email: "jimbob@southwest.us", password: "banjo" } ;
      user.save (err) ->
        if err
          console.log('BEFORE FAILED. WTF?!?')
        done()



    it 'should have no error lables when it first loads', (done) ->
      zombie.visit 'http://localhost:2999/register', (e, browser) ->
        browser.queryAll('.text-error').length.should.equal 0
        done()

    it 'should have error labels when submitted with invalid data', (done) ->
      zombie.visit 'http://localhost:2999/register', (e, browser) ->
        browser.pressButton '#register', ->
          browser.queryAll('.text-error').length.should.greaterThan 0
          done()

    it 'should return error label when no username entered', (done) ->
      zombie.visit 'http://localhost:2999/register', (e, browser) ->
        browser.pressButton '#register', ->
          browser.text('.text-error[for="user[username]"]').should.equal 'required'
          done()

    it 'should return error label when no email entered', (done) ->
      zombie.visit 'http://localhost:2999/register', (e, browser) ->
        browser.pressButton '#register', ->
          browser.text('.text-error[for="user[email]"]').should.equal 'required'
          done()

    it 'should return error label when no password entered', (done) ->
      zombie.visit 'http://localhost:2999/register', (e, browser) ->
        browser.fill('input[name="user[email]"]', 'email@email.com').fill('input[name="user[username]"]', 'Jahova').pressButton '#register', ->
          browser.text('.text-error[for="user[password]"]').should.equal 'required'
          done()

    it 'should return error label when invalid entered', (done) ->
          zombie.visit 'http://localhost:2999/register', (e, browser) ->
            browser.fill('input[name="user[email]"]', 'notanemail').pressButton '#register', ->
              browser.text('.text-error[for="user[email]"]').should.equal 'Must be valid email address'
              done()



