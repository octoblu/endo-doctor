async         = require 'async'
child_process = require 'child_process'
colors        = require 'colors'
cson          = require 'cson'
dashdash      = require 'dashdash'
_             = require 'lodash'
readlineSync  = require 'readline-sync'

packageJSON            = require './package.json'
ConfigureSchemaCheck   = require './src/checks/configure-schema-check'
CredentialsCheck       = require './src/checks/credentials-check'
DevicePermissionsCheck = require './src/checks/device-permissions-check'
EnvironmentCSONCheck   = require './src/checks/environment-cson-check'
ManagerURLCheck        = require './src/checks/manager-url-check'
# OptionsCheck           = require './src/checks/options-check'
PrivateKeyCheck        = require './src/checks/private-key-check'

OPTIONS = [{
  names: ['help', 'h']
  type: 'bool'
  help: 'Print this help and exit.'
}, {
  names: ['version', 'v']
  type: 'bool'
  help: 'Print the version and exit.'
}]

class Command
  constructor: ->
    process.on 'uncaughtException', @die
    {} = @parseOptions()

  parseOptions: =>
    parser = dashdash.createParser({options: OPTIONS})
    options = parser.parse(process.argv)

    if options.help
      console.log "usage: endo-doctor [OPTIONS]\noptions:\n#{parser.help({includeEnv: true})}"
      process.exit 0

    if options.version
      console.log packageJSON.version
      process.exit 0

    return options

  run: =>
    console.log "    Running checks"
    console.log "    ====================="
    async.series [
      async.apply @execute, 'Valid environment.cson', EnvironmentCSONCheck
      async.apply @execute, 'Check For Credentials', CredentialsCheck
      async.apply @execute, 'Check For Meshblu Private Key', PrivateKeyCheck
      async.apply @execute, 'Check For Device Permissions', DevicePermissionsCheck
      async.apply @execute, 'Check For Device Configure Schema', ConfigureSchemaCheck
      # async.apply @execute, 'Check For Device Options', OptionsCheck
      async.apply @execute, 'Check For Required Environment Params', ManagerURLCheck
    ], (error) =>
      return @die error if error?
      console.log colors.green '\nEverything looks good, lets try to fire it up!'
      @runEndo()

  runEndo: =>
    env = _.defaults cson.load('./environment.cson'), process.env
    npmStart = child_process.spawn 'npm', ['start'], {env}

    npmStart.stdout.on 'data', (data) =>
      process.stdout.write "#{data}"

    npmStart.stderr.on 'data', (data) =>
      process.stderr.write "#{data}"

    npmStart.on 'close', (code) =>
      console.log colors.red "\nUh oh, looks like there are still more problems. You're on your own for this one." if code != 0
      console.log("child process exited with code #{code}")
      process.exit code

  die: (error) =>
    return process.exit(0) unless error?
    console.error colors.red "\n#{error.message}\n"
    console.error error.description ? error.stack
    process.exit 1

  execute: (name, Check, next) =>
    check = new Check
    check.check (error) =>
      @displayResult name, error
      @offerResolution name, error, check.resolve, next

  exit: (error) =>
    return @die error if error?
    console.log colors.green '\nEverything looks good, rock on!'
    process.exit 0

  displayResult: (name, error) =>
    symbol = colors.green '√'
    symbol = colors.red 'x' if error?

    console.log "[#{symbol}] #{name}"

  offerResolution: (name, error, resolve, callback) =>
    return callback() unless error?
    console.log colors.red "\n#{error.message}"
    console.log error.description
    autoFix = readlineSync.keyInYN colors.yellow "\nWould you like me to try and automatically fix this?"
    return @rejectedExit() unless autoFix
    resolve (error) =>
      return @die error if error?
      console.log colors.green '\n\n\nI think I fixed it. Time to start over!\n'
      @run()

  rejectedExit: =>
    console.log "Ok then, just run me again when you've resolved this issue :-)"
    process.exit 1

module.exports = Command
