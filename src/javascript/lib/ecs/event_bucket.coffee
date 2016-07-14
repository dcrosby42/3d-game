# Immutable = require 'immutable'

# mkEvent = (name,data) ->
#   Immutable.fromJS
#     name: name
#     data: data

# class EventBucket
#   constructor: ->
#     @reset()
#
#   reset: ->
#     @entityEvents = Immutable.Map()
#     @globalEvents = Immutable.List()
#
#   getEventsForEntity: (eid) ->
#     es = @entityEvents.get(eid) || Immutable.List()
#     return es.concat(@globalEvents)
#
#   addEventForEntity: (eid, event, data=null) ->
#     es = @entityEvents.get(eid) || Immutable.List()
#     @entityEvents = @entityEvents.set eid, es.push(mkEvent(event,data))
#
#   addGlobalEvent: (event,data=null) ->
#     @globalEvents = @globalEvents.push(mkEvent(event,data))

class Event
  constructor: (@name,@data) ->

class EventBucket
  constructor: ->
    @reset()

  reset: ->
    @entityEvents = {}
    @globalEvents = []

  getEventsForEntity: (eid) ->
    @_entityEvents(eid).concat(@globalEvents)

  addEventForEntity: (eid, eventName, data=null) ->
    @_entityEvents(eid).push new Event(eventName,data)

  addGlobalEvent: (eventName,data=null) ->
    @globalEvents.push(new Event(eventName,data))

  _entityEvents: (eid) ->
    @entityEvents[eid] ?= []

module.exports = EventBucket

