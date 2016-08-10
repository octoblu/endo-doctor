cson          = require 'cson'
_             = require 'lodash'
MeshbluConfig = require 'meshblu-config'
MeshbluHTTP   = require 'meshblu-http'
path          = require 'path'

Errors  = require './errors'

class CredentialsCheck
  constructor: ({@fs, @meshbluParams, @readlineSync}={}) ->
    @fs            ?= require 'fs'
    @meshbluParams ?= {}
    @readlineSync  ?= require 'readline-sync'

  check: (callback) =>
    @_getEnvironment (error, environment) =>
      return callback error if error?
      return callback Errors.CREDENTIALS_MISSING() unless _.has environment, 'MESHBLU_UUID', 'MESHBLU_TOKEN'

      meshbluConfig = new MeshbluConfig({}, {}, env: environment).toJSON()
      meshblu = new MeshbluHTTP _.defaults meshbluConfig, @meshbluParams
      meshblu.whoami (error) =>
        return callback Errors.CREDENTIALS_INVALID() if error?
        return callback()

  resolve: (callback) =>
    userUUID = @readlineSync.question "What is your user's UUID? Can be found at https://app.octoblu.com/profile: "

    @_register userUUID, (error, credentials) =>
      return callback error if error?
      @_updateEnvironmentCSON credentials, callback

  _getEnvironment: (callback) =>
    @fs.readFile './environment.cson', (error, environmentStr) =>
      return callback error if error?
      return callback null, cson.parseCSONString(environmentStr)

  _getRegisterParams: (userUUID, callback) =>
    projectName = path.basename process.cwd()

    return callback null, {
      owner: userUUID
      type: 'device:oauth'
      name: projectName
      discoverWhitelist:  [userUUID]
      configureWhitelist: [userUUID]
    }

  _register: (userUUID, callback) =>
    @_getEnvironment (error, environment) =>
      return callback error if error?

      @_getRegisterParams userUUID, (error, registerParams) =>
        return callback error if error?

        meshbluConfig = new MeshbluConfig({}, {}, env: environment).toJSON()
        meshblu = new MeshbluHTTP meshbluConfig
        meshblu.register registerParams, (error, device) =>
          return callback error if error
          return callback null, MESHBLU_UUID: device.uuid, MESHBLU_TOKEN: device.token

  _updateEnvironmentCSON: (credentials, callback) =>
    @fs.readFile './environment.cson', (error, environmentStr) =>
      return callback error if error?
      environment = _.defaults credentials, cson.parse(environmentStr)

      @fs.writeFile './environment.cson', cson.stringify(environment), (error) =>
        callback error


module.exports = CredentialsCheck
