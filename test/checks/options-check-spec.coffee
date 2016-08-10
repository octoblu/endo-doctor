{afterEach, beforeEach, describe, it} = global
{expect}      = require 'chai'

cson          = require 'cson'
_             = require 'lodash'
mockFS        = require 'mock-fs'
enableDestroy = require 'server-destroy'
shmock        = require 'shmock'

OptionsCheck = require '../../src/checks/configure-schema-check'

describe 'OptionsCheck', ->
  beforeEach ->
    @meshblu = shmock()
    @meshblu_url = "http://localhost:#{@meshblu.address().port}"
    enableDestroy @meshblu

    @fs = mockFS.fs()
    @fs.writeFileSync './environment.cson', cson.stringify MESHBLU_UUID: 'uuid', MESHBLU_TOKEN: 'token'

    @sut = new OptionsCheck {@fs, meshbluParams: {
      protocol: 'http'
      hostname: 'localhost'
      port: @meshblu.address().port
    }}

  afterEach (done) ->
    @meshblu.destroy done

  describe '->check', ->
    describe 'when the device has a option', ->
      beforeEach ->
        auth = new Buffer('uuid:token').toString 'base64'

        @meshblu
          .get '/v2/whoami'
          .set 'Authorization', "Basic #{auth}"
          .reply 200, uuid: 'uuid', options: undefined

      it 'should yield an error', (done) ->
        @sut.check (error) =>
          expect(error).to.exist
          expect(error.message).to.deep.equal 'Options are missing'
          expect(error.description).to.exist
          done()

    describe 'when the device has a blank value for imageUrl', ->
      beforeEach ->
        auth = new Buffer('uuid:token').toString 'base64'

        @meshblu
          .get '/v2/whoami'
          .set 'Authorization', "Basic #{auth}"
          .reply 200, uuid: 'uuid', options: {imageUrl: ''}

      it 'should yield an error', (done) ->
        @sut.check (error) =>
          expect(error).to.exist
          expect(error.message).to.deep.equal 'Options are missing'
          expect(error.description).to.exist
          done()

    describe 'when the device does have the correct schema', ->
      beforeEach ->
        auth = new Buffer('uuid:token').toString 'base64'

        @meshblu
          .get '/v2/whoami'
          .set 'Authorization', "Basic #{auth}"
          .reply 200, uuid: 'uuid', optionsSchema: _.cloneDeep OPTIONS_SCHEMA

      it 'should not yield an error', (done) ->
        @sut.check (error) =>
          expect(error).not.to.exist
          done()

  describe '->resolve', ->
    beforeEach (done) ->
      auth = new Buffer('uuid:token').toString 'base64'
      @update = @meshblu
        .put '/v2/devices/uuid'
        .set 'Authorization', "Basic #{auth}"
        .send {$set: {optionsSchema: OPTIONS_SCHEMA}}
        .reply 204

      @sut.resolve done

    it 'should add "*" to the discover whitelist', ->
      expect(@update.isDone).to.be.true
