should = require 'should'
zombie = require 'zombie'
Users = require '../Models/User.js'
PasswordResets = require '../Models/PasswordReset.js'
mongoose = require 'mongoose'

user = null
password_reset = null

before  (done) ->
  user = new Users.User ({ username: "jimbob2", email: "jimbob2@southwest.us", password: "banjo" })
  user.save (err) ->
    if err
      console.log err

    password_reset = new PasswordResets.PasswordReset()
    password_reset.user = user._id
    password_reset.save  ->
      done()

describe 'PasswordReset', ->

  it 'should have a token that looks something like a guid', (done) ->
    password_reset.token.length.should.equal 36
    done()

  it 'should get timestamped', (done) ->
    password_reset.requested.getDate().should.equal new Date().getDate()
    done()

  it 'should report as valid if less than 24 hours old', (done) ->

    password_reset.isValid.should.equal true
    done()

  it 'should report as invalid if more than 24 hours old', (done) ->
    two_days_ago = new Date()
    two_days_ago.setDate(new Date().getDate()-2)
    password_reset.requested = two_days_ago
    password_reset.isValid.should.equal false
    done()