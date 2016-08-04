async        = require 'async'
colors       = require 'colors'
dashdash     = require 'dashdash'
readlineSync = require 'readline-sync'

packageJSON      = require './package.json'
EnvironmentCSONCheck  = require './src/checks/environment-cson-check'
CredentialsCheck = require './src/checks/credentials-check'

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
      console.log "usage: meshblu-verifier-http [OPTIONS]\noptions:\n#{parser.help({includeEnv: true})}"
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
    ], @exit

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
    console.log colors.red error.description
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
