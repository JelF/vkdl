#!/usr/bin/env ruby 
# encoding: utf-8

$LOAD_PATH << './lib'
require 'vkontakte_api'
require 'pathname'
require 'cfg.rb'
require 'namer.rb'

module Main
  ROOT=Pathname.new $cfg['ROOT'] 
  WGET = $cfg['WGET']
  BROWSER = $cfg['BROWSER']
  @namer = Namer.new ROOT

  def self.es(path)
    path.mkdir if !path.exist?
  end

  def self.prp(str)
    @namer.lookup(str)
  end

  def self.get
    VkontakteApi.configure do |cfg|
      cfg.app_id = $cfg['APP_ID']
      cfg.app_secret = $cfg['APP_SECRET']
      cfg.redirect_uri = 'http://api.vkontakte.ru/blank.html'
    end

    system  %[#{BROWSER} "#{VkontakteApi.authorization_url(type: :client, scope: [:audio])}" >/dev/null &] if !@token
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
  def self.download(sound)
    es ROOT
    i=0
    max = sound.length 
    sound.each do |snd|
      (folder,title) = @namer.lookup2 snd
      folder = ROOT+folder
      es folder
      `#{WGET} -c -O "#{(folder+title).to_path}.mp3" #{snd.url}`
      i=i+1
      puts "Downlading #{title} into #{folder}, #{i}/#{max} (#{i/max*100}%)"
    end
  end
  def self.start
    self.download self.get
  end
end
