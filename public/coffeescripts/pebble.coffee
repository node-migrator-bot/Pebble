# Public distributable version of the client.

class Pebble
  
  @run: (host, callback) ->
    pebble = new Pebble
    callback pebble
    pebble
    
  constructor: (host) ->
    @events = {}
    @socket = io.connect host
    
  on: (event, callback) ->
    @events[event]?= []
    @events[event].push callback
    
  watchAll: (channels...) ->
    for name, callback of channels
      @watch name, callback
  
  watch: (channel, callback) ->
    @on channel, callback
    @loadHistory channel, =>
      @socket.on channel, (data) => @receive channel, data
  
  trigger: (name, args...) ->
    callbacks = (@events[name] ?= [])
    for callback in callbacks
      callback.apply this, args
    
  disconnected: (callback) -> @on 'disconnect', callback
  connected:    (callback) -> @on 'connect',    callback
  reconnected:  (callback) -> @on 'reconnect',  callback
  
  receive: (channel, message, opts = {}) ->
    @trigger channel, message, opts
    
  loadHistory: (channel, callback) ->
    $.getJSON "/history/#{channel}", (data) =>
      for message in data.reverse()
        @receive channel, message, initial: true, loaded: (message is data[0])
      callback() if callback instanceof Function

window['Pebble'] = Pebble