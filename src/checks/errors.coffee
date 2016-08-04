_ = require 'lodash'

class Errors
  @CREDENTIALS_MISSING: =>
    _.tap new Error('Missing Meshblu Credentials'), (error) =>
      error.description = '''
        To resolve this issue, create an Oauth device at https://app.octoblu.com/node-wizard/add/551478c1537bdd6e20c9c608
        Then, populate MESHBLU_UUID and MESHBLU_TOKEN values in the environment.cson file.
      '''

  @CREDENTIALS_INVALID: =>
    _.tap new Error('Meshblu Credentials are Invalid'), (error) =>
      error.description = '''
        To resolve this issue, make sure the MESHBLU_UUID and MESHBLU_TOKEN values in the environment.cson file are
        correct. Warning: If you have me resolve it, I'm gonna create you a brand new device.
      '''

  @ENVIRONMENT_CSON_MISSING: =>
    _.tap new Error('Missing environment.cson file'), (error) =>
      error.description = '''
        To resolve this issue, create an environment.cson file at the root of the endo project directory.
      '''

  @ENVIRONMENT_CSON_PERMISSIONS: =>
    _.tap new Error('Found environment.cson, but the current user does not have read & write permissions'), (error) =>
      error.description = '''
        To resolve this issue, change the environment.cson permissions so the current user can read it. On Linux/macOS:

        chmod u+rw ./environment.cson
      '''

module.exports = Errors
