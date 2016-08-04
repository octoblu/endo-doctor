_ = require 'lodash'

class Errors
  @ENVIRONMENT_CSON_MISSING_ERROR: =>
    _.tap new Error('Missing environment.cson file'), (error) =>
      error.description = '''
        To resolve this issue, create an environment.cson file at the root of the endo project directory.
      '''

  @ENVIRONMENT_CSON_PERMISSIONS_ERROR: =>
    _.tap new Error('Found environment.cson, but the current user does not have read & write permissions'), (error) =>
      error.description = '''
        To resolve this issue, change the environment.cson permissions so the current user can read it. On Linux/macOS:

        chmod u+rw ./environment.cson
      '''

module.exports = Errors
