{afterEach, beforeEach, describe, it} = global
{expect}      = require 'chai'
cson          = require 'cson'
mockFS        = require 'mock-fs'
enableDestroy = require 'server-destroy'
shmock        = require 'shmock'
sinon         = require 'sinon'

CredentialsCheck = require '../../src/checks/credentials-check'

describe 'checkForCredentials', ->
  beforeEach ->
    @meshblu = shmock()
    @meshblu_url = "http://localhost:#{@meshblu.address().port}"
    enableDestroy @meshblu

    @fs = mockFS.fs()
    @readlineSync = {}

    @sut = new CredentialsCheck {@fs, @readlineSync, meshbluParams: {
      protocol: 'http'
      hostname: 'localhost'
      port: @meshblu.address().port
    }}

  afterEach (done) ->
    @meshblu.destroy done

  describe '->check', ->
    describe 'when there is no MESHBLU_UUID or MESHBLU_TOKEN', ->
      beforeEach ->
        @fs.writeFileSync 'environment.cson', ''

      it 'should yield an error', (done) ->
        @sut.check (error) =>
          expect(error).to.exist
          expect(error.message).to.deep.equal 'Missing Meshblu Credentials'
          expect(error.description).to.exist
          done()

    describe 'when there is an invalid MESHBLU_UUID or MESHBLU_TOKEN', ->
      beforeEach ->
        auth = new Buffer("uuid:token").toString('base64')

        @meshblu
          .get '/v2/whoami'
          .set 'Authorization', "Basic #{auth}"
          .reply 403, 'Forbidden'

        @fs.writeFileSync 'environment.cson',  cson.createCSONString(MESHBLU_UUID: 'uuid', MESHBLU_TOKEN: 'token')

      it 'should yield an error', (done) ->
        @sut.check (error) =>
          expect(error).to.exist
          expect(error.message).to.deep.equal 'Meshblu Credentials are Invalid'
          expect(error.description).to.exist
          done()

    describe 'when there is a valid MESHBLU_UUID and MESHBLU_TOKEN', ->
      beforeEach ->
        auth = new Buffer("uuid:token").toString('base64')

        @meshblu
          .get '/v2/whoami'
          .set 'Authorization', "Basic #{auth}"
          .reply 200, uuid: 'uuid'

        @fs.writeFileSync 'environment.cson',  cson.createCSONString(MESHBLU_UUID: 'uuid', MESHBLU_TOKEN: 'token')

      it 'should yield no error', (done) ->
        @sut.check (error) =>
          expect(error).not.to.exist
          done()

  describe '->resolve', ->
    beforeEach (done) ->
      @fs.writeFileSync './environment.cson', cson.stringify({})
      @readlineSync.question = sinon.stub().returns 'user-uuid'
      @register = @meshblu
        .post '/devices'
        .send
          owner: 'user-uuid'
          type: 'device:oauth'
          name: 'endo-doctor'
          discoverWhitelist:  ['user-uuid']
          configureWhitelist: ['user-uuid']
        .reply 201, {uuid: 'new-uuid', token: 'new-token'}
      @sut.resolve done

    it 'should ask the user their uuid', ->
      expect(@readlineSync.question).to.have.been.called

    it 'should register a new device with meshblu', ->
      expect(@register.isDone).to.be.true

    it 'should store the credentials in environment.cson', ->
      environment = cson.parse @fs.readFileSync './environment.cson'
      expect(environment).to.containSubset {
        MESHBLU_UUID:  'new-uuid'
        MESHBLU_TOKEN: 'new-token'
      }
