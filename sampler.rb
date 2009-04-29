#!/usr/bin/ruby
require 'gtk2'
require 'soundplayer'

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
