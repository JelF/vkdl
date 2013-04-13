#!/usr/bin/env ruby 
# encoding: utf-8

$LOAD_PATH << './lib'
require 'vkontakte_api'
require 'pathname'
require 'cfg.rb'
require 'namer.rb'
require 'downloader.rb'

VkontakteApi.configure do |cfg|
  cfg.app_id = $cfg['APP_ID']
  cfg.app_secret = $cfg['APP_SECRET']
  cfg.redirect_uri = 'http://api.vkontakte.ru/blank.html'
end

class  Vk_get
  def initialize
    @ROOT=Pathname.new $cfg['ROOT'] 
    @BROWSER = $cfg['BROWSER']
    @namer = Namer.new @ROOT
  end
  def get
    system  %[#{@BROWSER} "#{VkontakteApi.authorization_url(type: :client, scope: [:audio])}" >/dev/null &] if !@token
    while !@token
      STDERR.print "enter token:\t"
      @token = STDIN.gets.split("\n").first 
      begin 
        @vk = VkontakteApi::Client.new @token
        @sound = @vk.audio.get
      rescue 
        puts "Something goes wrong (probably bad token)"
        puts "C+c to break"
        @token=nil
      end
    end
    @sound
  end
end
