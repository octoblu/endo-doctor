cson        = require 'cson'
_           = require 'lodash'
MeshbluHTTP = require 'meshblu-http'

Errors  = require './errors'

class CredentialsCheck
  constructor: ({@fs, @meshbluParams, @readlineSync}={}) ->
    @fs            ?= require 'fs'
    @meshbluParams ?= {}
    @readlineSync  ?= require 'readline-sync'

  check: (callback) =>
    @_getEnvironment (error, MESHBLU_UUID, MESHBLU_TOKEN) =>
      return callback error if error?

      meshblu = new MeshbluHTTP _.defaults {uuid: MESHBLU_UUID, token: MESHBLU_TOKEN}, @meshbluParams
      meshblu.authenticate (error) =>
        return callback Errors.CREDENTIALS_INVALID() if error?
        return callback()

  resolve: (callback) =>
    userUuid = @readlineSync.question "What is your user's UUID? Can be found at https://app.octoblu.com/profile"
    meshblu = new MeshbluHTTP @meshbluParams
    meshblu.register {
      owner: userUuid
      discoverWhitelist:  [userUuid]
      configureWhitelist: [userUuid]
    }, (error) =>
      callback(error)

  _getEnvironment: (callback) =>
    @fs.readFile './environment.cson', (error, environmentStr) =>
      return callback error if error?
      {MESHBLU_UUID, MESHBLU_TOKEN} = cson.parseCSONString environmentStr

      return callback Errors.CREDENTIALS_MISSING() unless MESHBLU_UUID? && MESHBLU_TOKEN?
      return callback null, MESHBLU_UUID, MESHBLU_TOKEN

module.exports = CredentialsCheck
