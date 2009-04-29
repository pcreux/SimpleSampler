#!/usr/bin/ruby
# Copyright (c) 2009 Philippe Creux
# Simple Sampler plays a sound when you push its button.
require 'gtk2'
require 'soundplayer'

# This class create a Gtk::ToggleButton linked to a sound file.
# Send "toggle", it plays the sound. Send "toggle" again, it stops.
class SamplerButton < Gtk::ToggleButton
  def initialize (file = '')
    @label, @repeat = File.basename(file, '.mp3').split('-')
    @label.capitalize!
    @repeat = @repeat == 'repeat'
    @sound = SoundPlayer.new(file)
    super(@label)
    self.signal_connect('toggled') { self.toggle }
  end
  
  def play
    @sound.play
    @sound.play while self.active? && @repeat
    self.set_active false
  end

  def stop
    @sound.stop
  end

  def toggle
    self.active? ? self.play : self.stop
  end
end


# 1. Initialize a gtk window
# 2. Add a frame for each subdirectory of 'sounds'
# 3. Add a button for each sound to a subdir frame
def main
  window = Gtk::Window.new(Gtk::Window::TOPLEVEL)
  window.set_title  "Simple sampler"
  window.border_width = 10
  window.signal_connect('delete_event') { Gtk.main_quit }

  framebox = Gtk::HBox.new(true, 5)

  soundsdir = Dir.glob(File.join(File.dirname(__FILE__), 'sounds', '*'))
  soundsdir.each { |directory|
    sounds = Dir.glob(File.join(File.dirname(__FILE__), 'sounds', File.basename(directory), '*'))
    frame = Gtk::Frame.new(File.basename(directory).to_s)
    frame.add(soundbox = Gtk::VBox.new(false, 5))
    sounds.each { |sound|
      soundbox.add(SamplerButton.new(sound))
    }
    framebox.pack_start_defaults(frame)
  }

  window.add(framebox)
  window.show_all
  Gtk.main
end

main
