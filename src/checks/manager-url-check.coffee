cson = require 'cson'
path = require 'path'
_    = require 'lodash'

Errors = require './errors'

DEFAULT_MANAGER_URL = 'https://endo-manager.octoblu.com'

class ManagerURLCheck
  constructor: ({@fs}={}) ->
    @fs ?= require 'fs'

  check: (callback) =>
    @_getEnvironment (error, environment) =>
      return callback error if error?
      variableName = @_variableName()
      return callback Errors.MANAGER_URL_MISSING variableName if _.isEmpty environment[variableName]
      callback()

  resolve: (callback) =>
    @_getEnvironment (error, environment) =>
      environment = _.defaults {"#{@_variableName()}": DEFAULT_MANAGER_URL}, environment
      @fs.writeFile './environment.cson', cson.stringify(environment), callback

  _getEnvironment: (callback) =>
    @fs.readFile './environment.cson', (error, environmentStr) =>
      return callback error if error?
      return callback null, cson.parse environmentStr

  _variableName: =>
    endoPrefix = path.basename(process.cwd()).replace(/\-/g, '_').toUpperCase()
    return "#{endoPrefix}_MANAGER_URL"


module.exports = ManagerURLCheck
