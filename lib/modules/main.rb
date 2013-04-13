$LOAD_PATH<<'./lib'
require 'vk-get'
require 'namer'
require 'cfg'
require 'downloader'

module Main
  def self.start
    @namer = Namer.new $cfg['ROOT'] 
    @vkget = Vk_get.new
    @dler = Downloader.new @namer, @vkget.get
    @dler.start
  end
end
