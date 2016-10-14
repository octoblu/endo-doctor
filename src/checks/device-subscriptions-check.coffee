cson          = require 'cson'
_             = require 'lodash'
MeshbluConfig = require 'meshblu-config'
MeshbluHTTP   = require 'meshblu-http'

Errors  = require './errors'

class DeviceSubscriptionsCheck
  constructor: ({@fs, @readlineSync}={}) ->
    @fs            ?= require 'fs'
    @meshbluParams ?= {}
    @readlineSync  ?= require 'readline-sync'

  check: (callback) =>
    @_getMeshblu (error, meshblu, uuid) =>
      return callback error if error?
      subscription = subscriberUuid: uuid, emitterUuid: uuid, type: 'message.received'
      @_getSubscriptions (error, subscriptions) =>
        return callback error if error?
        return callback Errors.DEVICE_SUBSCRIPTIONS_NOT_SUBSCRIBED() unless _.find subscriptions, subscription
        callback()

  resolve: (callback) =>
    @_getMeshblu (error, meshblu, uuid) =>
      return callback error if error?
      subscription = subscriberUuid: uuid, emitterUuid: uuid, type: 'message.received'
      meshblu.createSubscription subscription, callback

  _getSubscriptions: (callback) =>
    @_getMeshblu (error, meshblu, uuid) =>
      return callback error if error?
      meshblu.subscriptions uuid, callback

  _getMeshblu: (callback) =>
    @fs.readFile './environment.cson', (error, environmentStr) =>
      return callback error if error?
      environment = cson.parseCSONString environmentStr
      meshbluConfig = new MeshbluConfig({}, {}, env: environment).toJSON()

      callback null, new MeshbluHTTP(meshbluConfig), environment.MESHBLU_UUID

module.exports = DeviceSubscriptionsCheck
