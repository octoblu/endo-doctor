Errors = require './errors'

class EnvironmentCSON
  constructor: ({@fs}={}) ->
    @fs ?= require 'fs'

  check: (callback) =>
    @fs.access './environment.cson', @fs.F_OK, (error) =>
      return callback Errors.ENVIRONMENT_CSON_MISSING_ERROR() if error?

      @fs.access './environment.cson', (@fs.R_OK | @fs.W_OK), (error) =>
        return callback Errors.ENVIRONMENT_CSON_PERMISSIONS_ERROR() if error?
        callback()

module.exports = EnvironmentCSON
