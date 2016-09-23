{beforeEach, describe, it} = global
{expect}      = require 'chai'

cson          = require 'cson'
mockFS        = require 'mock-fs'

ServiceUrlCheck = require '../../src/checks/service-url-check'

describe 'ServiceUrlCheck', ->
  beforeEach ->
    @fs = mockFS.fs()
    @sut = new ServiceUrlCheck {@fs}

  describe '->check', ->
    describe 'when the ENDO_<NAME>_SERVICE_URL is missing', ->
      beforeEach ->
        @fs.writeFileSync './environment.cson', cson.stringify {}

      it 'should yield an error', (done) ->
        @sut.check (error) =>
          expect(error).to.exist
          expect(error.message).to.deep.equal 'Missing required environment variable ENDO_DOCTOR_SERVICE_URL'
          expect(error.description).to.exist
          done()

    describe 'when the ENDO_<NAME>_SERVICE_URL is present', ->
      beforeEach ->
        @fs.writeFileSync './environment.cson', cson.stringify(ENDO_DOCTOR_SERVICE_URL: 'https://foo.org')

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
      expect(environment.ENDO_DOCTOR_SERVICE_URL).to.deep.equal 'https://endodoctor.localtunnel.me'
