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

    if !@token
      system  "#{BROWSER} \"#{VkontakteApi.authorization_url(type: :client, scope: [:audio])}\" >/dev/null &"
      STDERR.print "enter token:\t"
      @token = STDIN.gets.split("\n").first 
      @vk = VkontakteApi::Client.new @token
    end

    @vk.audio.get
  end
  def self.download(sound)
    es ROOT
    i=0
    max = sound.length 
    sound.each do |snd|
      folder = ROOT+prp(snd['artist'])
      p folder
      es folder
      file = folder+(prp(snd['title'])+'.mp3')
      p file
      `#{WGET} -c -O '#{file.to_path}' #{snd['url']}`
      i=i+1
      print "#{i}/#{max}\n"
    end
  end
  def self.start
    self.download self.get
  end
end
