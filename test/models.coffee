should = require 'should'
zombie = require 'zombie'
Users = require '../Models/User.js'
PasswordResets = require '../Models/PasswordReset.js'
mongoose = require 'mongoose'

user = null

before  (done) ->
  user = new Users.User ({ username: "jimbob2", email: "jimbob2@southwest.us", password: "banjo" })
  user.save (err) ->
    if err
      console.log err
    done()

describe 'PasswordReset', ->

  it 'should have a token that looks something like a guid', (done) ->
    password_reset = new PasswordResets.PasswordReset()
    password_reset.user = user._id
    password_reset.save  ->
      password_reset.token.length.should.equal 36
      done()

