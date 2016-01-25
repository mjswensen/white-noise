{CompositeDisposable} = require 'atom'

module.exports = WhiteNoise =
  subscriptions: null
  audioCtx: new AudioContext
  buffer: null
  source: null
  gain: null

  activate: (state) ->
    @subscriptions = new CompositeDisposable
    @subscriptions.add atom.commands.add 'atom-workspace', 'white-noise:toggle': => @toggle()

  deactivate: ->
    @subscriptions.dispose()

  toggle: ->
    maxGain = 0.5
    fadeInTime = 1
    fadeOutTime = 0.25
    if !@buffer
      console.log 'creating initial white noise buffer'
      bufferSize = 4 * @audioCtx.sampleRate # 4 seconds
      @buffer = @audioCtx.createBuffer(1, bufferSize, @audioCtx.sampleRate)
      output = @buffer.getChannelData 0
      for i in [0...bufferSize]
        output[i] = Math.random() * 2 - 1
    if @source
      @gain.gain.linearRampToValueAtTime(maxGain, @audioCtx.currentTime)
      @gain.gain.linearRampToValueAtTime(0.0, @audioCtx.currentTime + fadeOutTime)
      @source.stop(@audioCtx.currentTime + fadeOutTime)
      @source = null
    else
      @source = @audioCtx.createBufferSource()
      @source.buffer = @buffer
      @source.loop = true
      @gain = @audioCtx.createGain()
      @source.connect @gain
      @gain.connect @audioCtx.destination
      @source.start()
      @gain.gain.linearRampToValueAtTime(0.0, @audioCtx.currentTime)
      @gain.gain.linearRampToValueAtTime(maxGain, @audioCtx.currentTime + fadeInTime)
