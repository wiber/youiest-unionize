# The main collection. Only inserts allowed. Unless by cron or hook.
@W = new Mongo.collection 'W'

# Each user / profile gets a 'bucket' of pre-joined data kept up to date
# only enough to load the app with only one findOne query
@WI = new Mongo.collection 'WI'

#Client and server..

# need a shared function that validates w objects
# that they follow rules..

# need a shared bunch of react functions for making html out of W

# shorthand log function
@l = (arguments) ->
  # console.time 'l'
  # for i in arguments
  #   console.log i
  #   for o in i
  #     console.log o
  # console.time 'l'