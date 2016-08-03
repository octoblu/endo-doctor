fs = require 'fs'

module.exports = (callback) =>
  fs.access './meshblu.json', fs.F_OK, (error) ->
    return callback missingCredentialsError() if error?
    fs.access './meshblu.json', fs.R_OK, callback

missingCredentialsError = =>
  error = new Error 'Missing Meshblu Credentials'
  error.description = '''
    To resolve this issue, create an Oauth device at https://app.octoblu.com/node-wizard/add/551478c1537bdd6e20c9c608
    Then, download a meshblu.json from the newly created device details page (Credentials: GENERATE -> DOWNLOAD) and
    place it at the root of this project.
  '''
  return  error

noPermissionsError = (ogError) =>
  error = new Error ogError.message
  error.description = '''
    To resolve this issue, change the permissions of the meshblu.json file to be readable by the current user. On
    Linux/macOS, it can usually be solved by running:

    chmod +r meshblu.json
  '''
  return  error
