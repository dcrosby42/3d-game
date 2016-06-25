class Address
  constructor: (@signal) ->

  send: (v) ->
    @signal.notify v

  flush: ->
    []

  forward: (fn=null) ->
    sig = new Signal()
    addr = new Address(sig)
    sig2 = if fn?
      fn(sig)
    else
      sig
    sig2.pipeToAddress(@)
    addr

  something: (fn) ->

class BufferedAddress extends Address
  constructor: ->
    @_buffer = []

  send: (v) ->
    @_buffer.push(v)

  flush: ->
    vs = @_buffer
    @_buffer = []
    vs


class Signal
  constructor: ->
    @_listeners = []
    @_current = null

  peek: ->
    @_current

  notify: (v) ->
    @_current = v
    f(@_current) for f in @_listeners

  subscribe: (f) ->
    @_listeners.push f

  map: (f) ->
    outSig = new Signal()
    @subscribe (v) ->
      outSig.notify(f(v))
    outSig

  mapN: (f, sigs...) ->
    outSig = new Signal()
    notify = (_) =>
      currs = (sig.peek() for sig in sigs)
      skip = false
      for x in currs
        skip = true if !x?
      outSig.notify(f(@peek(),currs...)) unless skip
    @subscribe notify
    for sig in sigs
      sig.subscribe notify
    outSig

  pipeToAddress: (addr) ->
    @subscribe (v) -> addr.send(v)

  merge: (sigs...) ->
    outSig = new Signal()
    for inSig in sigs
      inSig.subscribe (v) ->
        outSig.notify(v)
    @subscribe (v) ->
      outSig.notify(v)
    outSig

  keep: (f) ->
    outSig = new Signal()
    @subscribe (v) ->
      if f(v)
        outSig.notify(v)
    outSig

  reject: (f=isNull) ->
    @keep(negate(f))

  filter: (f=nonNull) ->
    @keep(f)

  filterMap: (f) ->
    outSig = new Signal()
    @subscribe (v) ->
      v2 = f(v)
      outSig.notify(v2) if v2?
    outSig

  # f(value,state)
  foldp: (f,initial=null) ->
    outSig = new Signal()
    state = initial
    @subscribe (v) ->
      state = f(v,state)
      outSig.notify state
    outSig

  dropRepeats: (eq=null) ->
    eq ?= (a,b) -> a == b
    last = null
    outSig = new Signal()
    @subscribe (v) =>
      if !eq(last,v)
        outSig.notify v
      last = v
    outSig

  sampleOn: (triggerSig) ->
    outSig = new Signal()
    triggerSig.subscribe (_) =>
      outSig.notify(@peek())
    outSig

  sliceOn: (triggerSig) ->
    buf = []
    @subscribe (v) ->
      buf.push(v)
    outSig = new Signal()
    triggerSig.subscribe (_) ->
      outSig.notify(buf)
      buf = []
    outSig





negate = (f) ->
  (v) -> !f(v)

isNull = (v) -> !v?

nonNull = negate(isNull)

class Mailbox
  constructor: ->
    @signal = new Signal()
    @address = new Address(@signal)

  sync: ->
    null

class BufferedMailbox
  constructor: ->
    @signal = new Signal()
    @address = new BufferedAddress()

  sync: ->
    @signal.notify v for v in @address.flush()
    null


class PostOffice
  constructor: ->
    @_mailboxes = []

  newBufferedMailbox: ->
    mbox = new BufferedMailbox()
    @_mailboxes.push(mbox)
    return mbox

  newMailbox: ->
    mbox = new Mailbox()
    @_mailboxes.push(mbox)
    return mbox

  sync: ->
    for mbox in @_mailboxes
      mbox.sync()
    null

  @simpleAddressAndSignal: ->
    signal = new Signal()
    address = new Address(signal)
    return [ address, signal ]

module.exports = PostOffice

# po = new PostOffice()
# mbox = po.newMailbox()
# mbox.signal.subscribe (x) -> console.log x
# mbox.address.send("hi")

# a2 = mbox.address.forward (x) -> "<<#{x}>>"
# a2.send "whoaaa"

# console.log "-----------------"
# mbox2 = po.newBufferedMailbox()
# mbox2.signal.subscribe (x) -> console.log x
# mbox2.address.send("one")
# mbox2.address.send("two")
# console.log "ok..."
# po.sync()
# mbox2.address.send("three")
# console.log "ok..."
# po.sync()

