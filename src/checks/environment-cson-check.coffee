cson   = require 'cson'
Errors = require './errors'

class EnvironmentCSON
  constructor: ({@fs}={}) ->
    @fs ?= require 'fs'

  check: (callback) =>
    @fs.access './environment.cson', @fs.F_OK, (error) =>
      return callback Errors.ENVIRONMENT_CSON_MISSING() if error?

      @fs.access './environment.cson', (@fs.R_OK | @fs.W_OK), (error) =>
        return callback Errors.ENVIRONMENT_CSON_PERMISSIONS() if error?
        callback()

  resolve: (callback) =>
    @fs.writeFile './environment.cson', cson.stringify({}), (error) =>
      return callback error if error?
      callback()

module.exports = EnvironmentCSON
