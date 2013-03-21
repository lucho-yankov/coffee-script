###
  This should handle coffe linting on coffeescript compilation in watch.

  You have to install and run node-osx-notifier.
  Notifications are available on OSX 10.8+

  To run this: coffee -w -r ./example_coffeescript_hook.coffee -c ./lets_brew_some.coffee
###

{print} = require 'sys'
{spawn} = require 'child_process'
querystring = require 'querystring'

# magic here... watch out
for m in module.parent.children
  path = m.id.split "/"
  name = path[path.length-1]
  if name == "coffee-script.js"
    CoffeeScript = m.exports
    break

CoffeeScript.on 'success', (task) ->
  pushNotification 'fail', {'remove': 'ALL'}
  runCoffeeLint()

CoffeeScript.on 'failure', (exception, task) ->
  query =
    remove: "Coffee",
    group: "Coffee",
    title: "CoffeeScript Compiler",
    message: "Compilation error in #{task.file}"

  pushNotification 'fail', query
  runCoffeeLint()
  process.stderr.write "#{exception}\n"

pushNotification = (type, query) ->
  curl = spawn "curl", ["http://localhost:1337/#{type}?#{querystring.stringify(query)}"]

runCoffeeLint = () ->
  lint = spawn "coffeelint", ["-f", "coffeelint_config.json", "-r", "./your_coffeescript_folder"]
  lint.on 'exit', (status) =>
    if status != 0
      print ''
      print output
      query =
        remove: "CoffeeLint",
        group: "CoffeeLint",
        title: "CoffeeLint",
        message: "CoffeeLint failed :("

      pushNotification 'fail', query

  output = ""
  lint.stderr.on 'data', (data) ->
    output += data.toString()
  lint.stdout.on 'data', (data) ->
    output += data.toString()
