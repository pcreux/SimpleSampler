# Copyright (c) 2009 Philippe Creux
# Simple ruby library playing sound files via gstreamer
require 'gst'

# This class play sound files via gstreamer.
class SoundPlayer

  # @file: path to a sound file
  def initialize(file)
    @pipeline = Gst::Pipeline.new
    
    file_src = Gst::ElementFactory.make("filesrc")
    file_src.location = file
    
    decoder = Gst::ElementFactory.make("decodebin")
    audio_convert = Gst::ElementFactory.make("audioconvert")
    audio_resample = Gst::ElementFactory.make("audioresample")
    audio_sink = Gst::ElementFactory.make("autoaudiosink")
    
    @pipeline.add(file_src, decoder, audio_convert, audio_resample, audio_sink)
    file_src >> decoder
    audio_convert >> audio_resample >> audio_sink
    
    decoder.signal_connect("new-decoded-pad") do |element, pad|
      sink_pad = audio_convert["sink"]
      pad.link(sink_pad)
    end
    
    @loop = GLib::MainLoop.new(nil, false)
    
    bus = @pipeline.bus
    bus.add_watch do |bus, message|
      case message.type
      when Gst::Message::EOS
        @loop.quit
      when Gst::Message::ERROR
        p message.parse
        @loop.quit
      end
      true
    end
  end

  # play the sound
  def play
    @pipeline.play
    begin
      @loop.run
    rescue Interrupt
    ensure
      @pipeline.stop
    end
  end

  # stop playing
  def stop
    @loop.quit
    @pipeline.stop
  end
end

