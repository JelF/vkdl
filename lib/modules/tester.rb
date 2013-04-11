# encode utf-8
$LOAD_PATH << './lib'
require 'modules/main'
require 'namer'

module Tester
  @@namer = Namer.new(Pathname.new '/tmp/lib')
  def self.get_artist_list
    sound = Main::get
    sound.map {|s| @@namer.lookup s.artist}
  end
end
