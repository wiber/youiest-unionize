# emulate a logged in user, this is user
@user = 'wiber'

@clearClientGroundDbs = ->
  WI.remove
    _id: user
  WI.remove
    _id: 'nicolson'
  WI.remove
    _id: 'elias'
  -> WI.find({}).count()

@flushGroundlings = ->
  pre = WI.find({}).count()
  cl = clearClientGroundDbs()
  smite 'did we flush the groundlings out?', pre, cl(), 'if 0 yes', eval s
  -> cl

ConsoleMe.enabled = true

@recFrom = 'picture'
@recNum = 0

@recommendation =
  to: user
  from: recFrom
@recommendationArray = []
for i in '0123456789'
  r =
    to: user+i
    from: recFrom+i
  @recommendationArray.push r
  smite recommendationArray[i], 'counting to recommendations',recommendationArray
  

Meteor.methods
  "dummyInsert" : (insert) ->
    
    #always clear db before inserting
    Meteor.call 'clearDb'
    
    WI.insert 
      _id: 'wiber'
    WI.insert 
      _id: 'elias'
    WI.insert
      _id: 'nicolson'


    #attempt to clear client ground db
    return clearClientGroundDbs
  "clearDb": () ->
    # smite eval(s), 'clearDb'
    W.remove {}
    WI.remove {}
    return null




Meteor.startup ->

  if Meteor.isClient
    Meteor.call 'dummyInsert', (res,err) ->
      smite res, err, 'returned from dummyinsert', eval s
      for recommend in recommendationArray
        # console.error(recommend)
        connect(recommend)
    Tinytest.addAsync 'clear - 0 call clearDb server clears db and client goes to 0 items', (test, next) ->
      smite WI.find({}).count(), 'items in WI before', eval s
      flushGroundlings()

      recNum = 0

      picd = Tracker.autorun (computation) ->
        recNum = 0
        smite WI.find({}).count(), 'items after tracker started', eval s
        one = WI.find({}).count()
        #smite one, two, eval s
        # search the console for 107 and instantly find this as the line number is here..
        eval smiter
        unless one
          smite 'got hit tracker zero', eval s
          test.equal one, 0
          next()

    Tinytest.addAsync 'update - 1 clientside update of WI should trigger insert into W', (test, next) ->

      recNum = 0
      smite 'connecting after test add', recNum
      , recommendationArray[recNum].to
      , recommendationArray[recNum].from
      , eval s
      c = connect(recommendationArray[recNum])
      smite c , 'returned from connect', eval s

      picd = Tracker.autorun (computation) ->
        recNum = 0
        smite recNum, 'ran tracker one', recommendationArray[recNum], eval s
        smite W.findOne({to:recommendationArray[recNum].to}) , recommendationArray[recNum].to, 'ran tracker one', eval s
        unless !W.findOne({to:recommendationArray[recNum].to})
          smite 'got hit tracker one', eval s
          test.equal recommendationArray[recNum].from, W.findOne({to:recommendationArray[recNum].to}).from
          next()

    Tinytest.addAsync 'update - 2 clientside update of WI should trigger insert into W', (test, next) ->

      recNum = 2
      c = connect(recommendationArray[recNum])
      smite c , 'returned from connect in 2', eval s
      picd = Tracker.autorun (computation) ->
        smite eval(s), 'ran tracker one'
        recNum = 2
        unless !W.findOne({to:recommendationArray[recNum].to})
          smite eval(s), 'got hit'
          db = W.findOne({to:recommendationArray[recNum].to}).from
          input = recommendationArray[recNum].from
          test.equal  input, db 
          next()
    # this test requires update on client, two update triggered on server and sync data back to client
    Tinytest.addAsync 'update - 3 client WI.outbox -> server W -> client WI.inbox', (test, next) ->

      recNum = 3
      c = connect(recommendationArray[recNum])
      smite c , 'returned from connect in tracker 3', recommendationArray[recNum].to, eval s
      
      picd = Tracker.autorun (computation) ->
        recNum = 3
        unless !recommendationArray[recNum].from
          ingoing = recommendationArray[recNum].from
        unless !WI.findOne(_id: recommendationArray[recNum].to) 
          unless WI.findOne(_id: recommendationArray[recNum].to).inbox
              out =  WI.findOne(_id: recommendationArray[recNum].to).inbox[0].from
            smite 'ran tracker three' , WI.findOne({inbox:{ $exists: true }}) , recommendationArray[recNum].from, eval s
            # don't test untill data arrives from server inbox
            unless !WI.findOne({_id: recommendationArray[recNum].to})
              smite eval(s), 'got hit 3'
              test.equal out , ingoing
              this.stop()
              next()


    # feed function adds a w to the feed cache, queries process best fits
    # for in loop generates feed items from specific function that generates styled react..
    # react pieces need to be a separate package?
    #TODO keep a feed fresh so WI.findOne get's enough to start an app, uses feed function? seeks to maintain a varying number of items
    # array with max 50 items, feed, 

    Tinytest.addAsync 'update - 4 client WI.outbox -> W -> WI.inbox', (test, next) ->
      
      recNum = 4
      c = connect(recommendationArray[recNum])
      smite c , 'returned from connect in tracker 3', recommendationArray[recNum].to, eval s
      picd = Tracker.autorun (computation) ->
        recNum = 4
        unless !recommendationArray[recNum].from
          ingoing = recommendationArray[recNum].from
        unless !WI.findOne(_id: recommendationArray[recNum].to)
          out =  WI.findOne(_id: recommendationArray[recNum].to).inbox[0].from
        smite 'ran tracker three' , WI.findOne({inbox:{ $exists: true }}) , recommendationArray[recNum].from, eval s
        # don't test untill data arrives from server inbox
        unless !ingoing
          smite eval(s), 'got hit 3'
          test.equal ingoing , out
          this.stop()
          next()
    
    #TODO test that groundb syncs back to server correctly even if new items exist server - conflicts?
    Tinytest.addAsync 'update - 5 client WI.outbox -> W -> WI.inbox', (test, next) ->
      
      recNum = 5
      c = connect(recommendationArray[recNum])
      smite c , 'returned from connect in tracker 3', recommendationArray[recNum].to, eval s
      picd = Tracker.autorun (computation) ->
        recNum = 5
        smite 'ran tracker three' , WI.findOne({inbox:{ $exists: true }}) , recommendationArray[recNum].from, eval s
        # don't test untill data arrives from server inbox
        if WI.findOne({_id: recommendationArray[recNum].to})?.inbox
          smite eval(s), 'got hit 3'
          test.equal WI.findOne(_id: recommendationArray[recNum].to).inbox[0].from , recommendationArray[recNum].from
          this.stop()
          next()

    #TODO moved from sending to sent when done, or have another collection with unfinished jobs from inserts if necessary
    Tinytest.addAsync 'update - 6 client WI.outbox -> W -> WI.inbox', (test, next) ->
      
      recNum = 6
      c = connect(recommendationArray[recNum])
      smite c , 'returned from connect in tracker 3', recommendationArray[recNum].to, eval s
      picd = Tracker.autorun (computation) ->
        recNum = 6
        smite 'ran tracker three' , WI.findOne({inbox:{ $exists: true }}) , recommendationArray[recNum].from, eval s
        # don't test untill data arrives from server inbox
        if WI.findOne({_id: recommendationArray[recNum].to})?.inbox
          smite eval(s), 'got hit 3'
          test.equal WI.findOne(_id: recommendationArray[recNum].to).inbox[0].from , recommendationArray[recNum].from
          this.stop()
          next()

    #TODO test Logged in security of WI
    Tinytest.addAsync 'update - 7 client WI.outbox -> W -> WI.inbox', (test, next) ->
      recNum = 7
      c = connect(recommendationArray[recNum])
      smite c , 'returned from connect in tracker 3', recommendationArray[recNum].to, eval s
      picd = Tracker.autorun (computation) ->
        recNum = 7
        smite 'ran tracker three' , WI.findOne({inbox:{ $exists: true }}) , recommendationArray[recNum].from, eval s
        # don't test untill data arrives from server inbox
        if WI.findOne({_id: recommendationArray[recNum].to})?.inbox
          smite eval(s), 'got hit 3'
          test.equal WI.findOne(_id: recommendationArray[recNum].to).inbox[0].from , recommendationArray[recNum].from
          this.stop()
          next()
          this.stop()
          # next()
    

# # TODO 
#   # Unionize as discussed
#     Tinytest.addAsync "reactjs - check the last data entered is in the dom for another1", (test, next) ->
#       testingRecommend = { from: 'another1', to: 'wiber6' }
#       connect(testingRecommend)
#       @secondReact = React.createClass
#         "getInitialState": ()->
#           {feeds: WI.findOne 
#             "_id": myWI}
#         "componentDidMount": ()->
#           self = @
#           Tracker.autorun ()->
#             feed = WI.findOne({"_id": myWI})   
#             self.setState({"feeds": feed})
#         "render": ()->
#           # console.error(this.state.feeds)
#           feedsList = []
#           if(this.state.feeds and this.state.feeds.outbox)
#             outbox = this.state.feeds.outbox
#             # console.error(outbox)
#             for feed in outbox
#               console.error(feed)
#               if(feed.from ==  'another1')
#                 test.equal(true,true)
#                 next()
#             feedsList = outbox.map (feed)->
#                 React.DOM.div(null)
#             # console.error(this.state.feeds.outbox.length,feedsList.length)
#             test.equal(this.state.feeds.outbox.length,feedsList.length)
            
#           return React.DOM.div(null,feedsList)
#       React.renderComponentToString(@secondReact(null))

#TODO
  #move from inbox to seen
    # Tinytest.addAsync "move - Move the data from inbox to seeing", (test, next) ->
    #   testingRecommend = { from: 'move1', to: 'wiber' }
    #   for i in "0...9"
    #     connect(testingRecommend)

      
    #   smite WI.findOne({"_id": myWI}), "data on WI", eval s