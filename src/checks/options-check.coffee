cson        = require 'cson'
_           = require 'lodash'
MeshbluHTTP = require 'meshblu-http'

Errors  = require './errors'

OPTIONS_SCHEMA = require '../schemas/optionsSchema'

class ConfigureSchemaCheck
  constructor: ({@fs, @readlineSync}={}) ->
    @fs            ?= require 'fs'
    @meshbluParams ?= {}
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
      {MESHBLU_UUID, MESHBLU_TOKEN} = cson.parseCSONString environmentStr
      params = _.defaults {uuid: MESHBLU_UUID, token: MESHBLU_TOKEN}, @meshbluParams

      callback null, new MeshbluHTTP(params), MESHBLU_UUID

module.exports = ConfigureSchemaCheck
