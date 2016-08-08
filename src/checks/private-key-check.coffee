ursa   = require 'ursa'
cson   = require 'cson'
Errors = require './errors'
_      = require 'lodash'

class EnvironmentCSON
  constructor: ({@fs}={}) ->
    @fs ?= require 'fs'

  check: (callback) =>
    @fs.readFile './environment.cson', (error, environmentStr) =>
      return callback error if error?
      {MESHBLU_PRIVATE_KEY} = cson.parseCSONString environmentStr

      return callback Errors.MESHBLU_PRIVATE_KEY_MISSING() unless MESHBLU_PRIVATE_KEY?
      return callback null, MESHBLU_PRIVATE_KEY

  resolve: (callback) =>
    @fs.readFile './environment.cson', (error, environmentStr) =>
      return callback error if error?
      privateKey = MESHBLU_PRIVATE_KEY: ursa.generatePrivateKey().toPrivatePem('base64')
      environment = _.defaults privateKey, cson.parse(environmentStr)

      @fs.writeFile './environment.cson', cson.stringify(environment), (error) =>
        callback error

module.exports = EnvironmentCSON
