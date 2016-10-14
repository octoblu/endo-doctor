path          = require 'path'
cson          = require 'cson'
_             = require 'lodash'
MeshbluConfig = require 'meshblu-config'
MeshbluHTTP   = require 'meshblu-http'

Errors  = require './errors'
class DeviceWebhookCheck
  constructor: ({@fs, @readlineSync}={}) ->
    @fs            ?= require 'fs'
    @meshbluParams ?= {}
    @readlineSync  ?= require 'readline-sync'

  check: (callback) =>
    @_getWebhook (error, webhook) =>
      return callback error if error?
      @_getDevice (error, device) =>
        return callback error if error?
        return callback Errors.DEVICE_WEBHOOK_MISSING() unless _.find device.meshblu?.forwarders?.message?.received, webhook
        callback()

  resolve: (callback) =>
    @_getMeshblu (error, meshblu, uuid) =>
      return callback error if error?
      @_getWebhook (error, webhook) =>
        return callback error if error?
        update =
          $set:
            'meshblu.forwarders.version': '2.0.0',
          $addToSet:
            'meshblu.forwarders.message.received': webhook
        meshblu.updateDangerously uuid, update, callback

  _getDevice: (callback) =>
    @_getMeshblu (error, meshblu) =>
      return callback error if error?
      meshblu.whoami callback

  _getWebhook: (callback) =>
    @_getServiceUrl (error, serviceUrl) =>
      return callback error if error?
      webhook =
        type: 'webhook'
        url: "#{serviceUrl}/v2/messages"
        method: 'POST'
        signRequest: true
      callback null, webhook

  _getServiceUrl: (callback) =>
    @_getEnvironment (error, environment) =>
      return callback error if error?
      callback null, environment[@_envName()]

  _envName: => "#{@_projectConstant()}_SERVICE_URL"

  _projectConstant: => _.toUpper _.snakeCase @_projectName()

  _projectName: => path.basename process.cwd()

  _getEnvironment: (callback) =>
    @fs.readFile './environment.cson', (error, environmentStr) =>
      return callback error if error?
      return callback null, cson.parse environmentStr

  _getMeshblu: (callback) =>
    @fs.readFile './environment.cson', (error, environmentStr) =>
      return callback error if error?
      environment = cson.parseCSONString environmentStr
      meshbluConfig = new MeshbluConfig({}, {}, env: environment).toJSON()

      callback null, new MeshbluHTTP(meshbluConfig), environment.MESHBLU_UUID

module.exports = DeviceWebhookCheck
