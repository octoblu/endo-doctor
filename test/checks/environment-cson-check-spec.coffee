{beforeEach, describe, it} = global
{expect} = require 'chai'
mockFS = require 'mock-fs'

EnvironmentCSON = require '../../src/checks/environment-cson-check'

describe 'EnvironmentCSON', ->
  beforeEach ->
    @fs  = mockFS.fs()
    @sut = new EnvironmentCSON {@fs}

  describe '->check', ->
    describe 'when the environment.cson file does not exist', ->
      beforeEach (done) ->
        @sut.check (@error) => done()

      it 'should yield an error', ->
        expect(@error).to.exist
        expect(@error.message).to.deep.equal 'Missing environment.cson file'
        expect(@error.description).to.exist

    describe 'when the environment.cson file does exist', ->
      beforeEach (done) ->
        @fs.writeFileSync './environment.cson', 'foo: "bar"'
        @sut.check (@error) => done()

      it 'should not yield an error', ->
        expect(@error).not.to.exist

    describe 'when the environment.cson file exists but has no read permissions', ->
      beforeEach (done) ->
        @fs.writeFileSync './environment.cson', 'foo: "bar"'
        @fs.chmodSync './environment.cson', 0o0222
        @sut.check (@error) => done()

      it 'should not yield an error', ->
      it 'should yield an error', ->
        expect(@error).to.exist
        expect(@error.message).to.deep.equal 'Found environment.cson, but the current user does not have read & write permissions'
        expect(@error.description).to.exist

    describe 'when the environment.cson file exists but has no write permissions', ->
      beforeEach (done) ->
        @fs.writeFileSync './environment.cson', 'foo: "bar"'
        @fs.chmodSync './environment.cson', 0o0444
        @sut.check (@error) => done()

      it 'should not yield an error', ->
      it 'should yield an error', ->
        expect(@error).to.exist
        expect(@error.message).to.deep.equal 'Found environment.cson, but the current user does not have read & write permissions'
        expect(@error.description).to.exist
