async = require 'async'
fs    = require 'fs'
_     = require 'lodash'

class CredentialsCheck
  constructor: ->

  check: (callback) =>
    async.series [ @_isFileCheck, @_hasAccessCheck], callback

  _isFileCheck: (callback) =>
    fs.access './meshblu.json', fs.F_OK, (error) =>
      return callback CredentialsCheck.MISSING_CREDENTIALS_ERROR() if error?
      @_isFile = true
      return callback()

  _hasAccessCheck: (callback) =>
    fs.access './meshblu.json', fs.R_OK, callback, (error) =>
      return callback CredentialsCheck.NO_PERMISSIONS_ERROR() if error?
      return callback()

  @MISSING_CREDENTIALS_ERROR: =>
    _.tap new Error('Missing Meshblu Credentials'), (error) =>
      error.description = '''
        To resolve this issue, create an Oauth device at https://app.octoblu.com/node-wizard/add/551478c1537bdd6e20c9c608
        Then, download a meshblu.json from the newly created device details page (Credentials: GENERATE -> DOWNLOAD) and
        place it at the root of this project.
      '''

  @NO_PERMISSIONS_ERROR: =>
    error = new Error 'Meshblu Credentials file is not readable'
    error.description = '''
      To resolve this issue, change the permissions of the meshblu.json file to be readable by the current user. On
      Linux/macOS, it can usually be solved by running:

      chmod +r meshblu.json
    '''
    return  error




module.exports = CredentialsCheck
