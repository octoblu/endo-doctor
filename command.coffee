async    = require 'async'
colors   = require 'colors'
dashdash = require 'dashdash'

packageJSON         = require './package.json'
checkForCredentials = require './src/check-for-credentials'

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
    async.series [
      @execute 'Check For Credentials', checkForCredentials
    ], @exit

  die: (error) =>
    return process.exit(0) unless error?
    console.error colors.red "\n#{error.message}\n"
    console.error error.description ? error.stack
    process.exit 1

  execute: (name, check) => # Don't worry about it
    (next) =>
      check (error) =>
        @processResult name, error
        next()

  exit: (error) =>
    return @die error if error?
    console.log colors.green '\nEverything looks good, rock on!'
    process.exit 0

  processResult: (name, error) =>
    symbol = colors.green '√'
    symbol = colors.red 'x' if error?

    console.log "[#{symbol}] #{name}"
    @exit error if error?

module.exports = Command
