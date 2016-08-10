cson          = require 'cson'
_             = require 'lodash'
MeshbluConfig = require 'meshblu-config'
MeshbluHTTP   = require 'meshblu-http'

Errors  = require './errors'

class DevicePermissionsCheck
  constructor: ({@fs, @readlineSync}={}) ->
    @fs            ?= require 'fs'
    @meshbluParams ?= {}
    @readlineSync  ?= require 'readline-sync'

  check: (callback) =>
    @_getDevice (error, device) =>
      return callback error if error?
      return callback Errors.DEVICE_PERMISSIONS_NOT_WORLD_DISCOVERABLE() unless _.includes device.discoverWhitelist, '*'
      callback()

  resolve: (callback) =>
    @_getMeshblu (error, meshblu, uuid) =>
      return callback error if error?
      meshblu.updateDangerously uuid, $addToSet: {discoverWhitelist: '*'}, callback

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

module.exports = DevicePermissionsCheck
