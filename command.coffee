colors        = require 'colors'
dashdash      = require 'dashdash'

packageJSON = require './package.json'

OPTIONS = [{
  names: ['example', 'e']
  type: 'string'
  env: 'EXAMPLE'
  help: 'example argument'
}, {
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
    {@example} = @parseOptions()

  parseOptions: =>
    parser = dashdash.createParser({options: OPTIONS})
    options = parser.parse(process.argv)

    if options.help
      console.log "usage: meshblu-verifier-http [OPTIONS]\noptions:\n#{parser.help({includeEnv: true})}"
      process.exit 0

    if options.version
      console.log packageJSON.version
      process.exit 0

    if !options.example
      console.error "usage: meshblu-verifier-http [OPTIONS]\noptions:\n#{parser.help({includeEnv: true})}"
      console.error colors.red 'Missing required parameter --example, -e, or env: EXAMPLE'
      process.exit 1

    return options

  run: =>
    console.log "Hi Example! #{@example}"

  die: (error) =>
    return process.exit(0) unless error?
    console.error 'ERROR'
    console.error error.stack
    process.exit 1

module.exports = Command
