cson          = require 'cson'
_             = require 'lodash'
MeshbluHTTP   = require 'meshblu-http'
MeshbluConfig = require 'meshblu-config'

Errors  = require './errors'

OPTIONS_SCHEMA = require '../schemas/optionsSchema'

class ConfigureSchemaCheck
  constructor: ({@fs, @readlineSync}={}) ->
    @fs            ?= require 'fs'
    @readlineSync  ?= require 'readline-sync'

  check: (callback) =>
    @_getDevice (error, device) =>
      return callback error if error?
      return callback Errors.CONFIGURE_SCHEMA_INCORRECT() unless _.isEqual device.optionsSchema, OPTIONS_SCHEMA
      callback()

  resolve: (callback) =>
    @_getMeshblu (error, meshblu, uuid) =>
      return callback error if error?
      meshblu.updateDangerously uuid, $set: {optionsSchema: OPTIONS_SCHEMA}, callback

  _getDevice: (callback) =>
    @_getMeshblu (error, meshblu) =>
      return callback error if error?
      meshblu.whoami callback

  _getMeshblu: (callback) =>
    @fs.readFile './environment.cson', (error, environmentStr) =>
      return callback error if error?
      environment = cson.parseCSONString environmentStr
      meshbluConfig = new MeshbluConfig({}, {}, env: environment).toJSON()

      callback null, new MeshbluHTTP(meshbluConfig), environment.MESHBLU_UUID

module.exports = ConfigureSchemaCheck
