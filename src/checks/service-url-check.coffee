cson = require 'cson'
_    = require 'lodash'
path = require 'path'

Errors = require './errors'

class ManagerURLCheck
  constructor: ({@fs}={}) ->
    @fs ?= require 'fs'

  check: (callback) =>
    @_getEnvironment (error, environment) =>
      return callback error if error?
      return callback Errors.SERVICE_URL_MISSING(@_envName()) if _.isEmpty environment[@_envName()]
      callback()

  resolve: (callback) =>
    @_getEnvironment (error, environment) =>
      environment = _.defaults {"#{@_envName()}": @_defaultValue()}, environment
      @fs.writeFile './environment.cson', cson.stringify(environment), callback

  _defaultValue: =>
    subdomain = _.replace _.snakeCase(@_projectName()), /_/g, ''
    @defaultValue = "https://#{subdomain}.localtunnel.me"

  _envName: => "#{@_projectConstant()}_SERVICE_URL"

  _getEnvironment: (callback) =>
    @fs.readFile './environment.cson', (error, environmentStr) =>
      return callback error if error?
      return callback null, cson.parse environmentStr

  _projectConstant: => _.toUpper _.snakeCase @_projectName()
  _projectName: => path.basename process.cwd()

module.exports = ManagerURLCheck
