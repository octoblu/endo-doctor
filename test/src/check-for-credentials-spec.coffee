{afterEach, beforeEach, describe, it} = global
{expect} = require 'chai'
mockFS   = require 'mock-fs'

checkForCredentials = require '../../src/check-for-credentials'

describe 'checkForCredentials', ->
  describe 'when the meshblu.json is missing', ->
    it 'should yield an error', (done) ->
      checkForCredentials (error) =>
        expect(error.message).to.deep.equal 'Missing Meshblu Credentials'
        expect(error.description).to.exist
        done()

  describe 'when the meshblu.json is present', ->
    beforeEach ->
      meshbluJSON = JSON.stringify({
        uuid: 'uuid'
        token: 'token'
        domain: 'octoblu.com'
        resolveSrv: true
      })

      mockFS 'meshblu.json': meshbluJSON

    afterEach ->
      mockFS.restore()

    it 'should not yield an error', (done) ->
      checkForCredentials (error) =>
        expect(error).not.to.exist
        done()

  describe 'when the meshblu.json is present but not readable', ->
    beforeEach ->
      meshbluJSON = JSON.stringify({
        uuid: 'uuid'
        token: 'token'
        domain: 'octoblu.com'
        resolveSrv: true
      })

      mockFS({
        'meshblu.json': mockFS.file({
          content: meshbluJSON
          mode:    0o0000
        })
      })

    afterEach ->
      mockFS.restore()

    it 'should yield an error', (done) ->
      checkForCredentials (error) =>
        expect(error).to.exist
        expect(error.message).to.deep.equal "EACCES, permission denied './meshblu.json'"
        done()
