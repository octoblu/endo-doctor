cson = require 'cson'
_    = require 'lodash'

Errors = require './errors'

DEFAULT_APP_OCTOBLU_HOST = 'https://app.octoblu.com/'

class ManagerURLCheck
  constructor: ({@fs}={}) ->
    @fs ?= require 'fs'

  check: (callback) =>
    @_getEnvironment (error, environment) =>
      return callback error if error?
      return callback Errors.APP_OCTOBLU_HOST_MISSING() if _.isEmpty environment['APP_OCTOBLU_HOST']
      callback()

  resolve: (callback) =>
    @_getEnvironment (error, environment) =>
      environment = _.defaults {APP_OCTOBLU_HOST: DEFAULT_APP_OCTOBLU_HOST}, environment
      @fs.writeFile './environment.cson', cson.stringify(environment), callback

  _getEnvironment: (callback) =>
    @fs.readFile './environment.cson', (error, environmentStr) =>
      return callback error if error?
      return callback null, cson.parse environmentStr

module.exports = ManagerURLCheck
