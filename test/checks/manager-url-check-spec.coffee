{afterEach, beforeEach, describe, it} = global
{expect}      = require 'chai'

cson          = require 'cson'
mockFS        = require 'mock-fs'
enableDestroy = require 'server-destroy'
shmock        = require 'shmock'

ManagerURLCheck = require '../../src/checks/manager-url-check'

describe 'ManagerURLCheck', ->
  beforeEach ->
    @meshblu = shmock()
    @meshblu_url = "http://localhost:#{@meshblu.address().port}"
    enableDestroy @meshblu

    @fs = mockFS.fs()

    @sut = new ManagerURLCheck {@fs, meshbluParams: {
      protocol: 'http'
      hostname: 'localhost'
      port: @meshblu.address().port
    }}

  afterEach (done) ->
    @meshblu.destroy done

  describe '->check', ->
    describe 'when the ENDO_<CHANNEL>_MANAGER_URL is missing', ->
      beforeEach ->
        @fs.writeFileSync './environment.cson', cson.stringify {}
        auth = new Buffer('uuid:token').toString 'base64'

        @meshblu
          .get '/v2/whoami'
          .set 'Authorization', "Basic #{auth}"
          .reply 200, uuid: 'uuid', discoverWhitelist: ['user-uuid']

      it 'should yield an error', (done) ->
        @sut.check (error) =>
          expect(error).to.exist
          expect(error.message).to.deep.equal 'Missing required environment variable ENDO_DOCTOR_MANAGER_URL'
          expect(error.description).to.exist
          done()

    describe 'when the ENDO_<CHANNEL>_MANAGER_URL is present', ->
      beforeEach ->
        @fs.writeFileSync './environment.cson', cson.stringify {ENDO_DOCTOR_MANAGER_URL: 'https://foo.org'}
        auth = new Buffer('uuid:token').toString 'base64'

        @meshblu
          .get '/v2/whoami'
          .set 'Authorization', "Basic #{auth}"
          .reply 200, uuid: 'uuid', discoverWhitelist: ['user-uuid']

      it 'should not yield an error', (done) ->
        @sut.check (error) =>
          expect(error).not.to.exist
          done()

  describe '->resolve', ->
    beforeEach (done) ->
      @fs.writeFileSync './environment.cson', cson.stringify {}
      @sut.resolve done

    it 'should add the default url to the environment file', ->
      environment = cson.parse @fs.readFileSync './environment.cson'
      expect(environment.ENDO_DOCTOR_MANAGER_URL).to.deep.equal 'https://endo-manager.octoblu.com'
