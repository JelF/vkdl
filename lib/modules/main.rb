#!/usr/bin/env ruby 
# encoding: utf-8

$LOAD_PATH << './lib'
require 'vkontakte_api'
require 'pathname'
require 'cfg.rb'

module Main
  ROOT=Pathname.new $cfg['ROOT'] 
  WGET = $cfg['WGET']
  BROWSER = $cfg['BROWSER']

  def self.es(path)
    path.mkdir if !path.exist?
  end

  def self.prp(str)
    str.gsub!(/[^0-9a-zA-Zа-яА-Я\s\-]/,'_')
    str.gsub!(/(\s)$/,'_')
    str
  end

  def self.start
    VkontakteApi.configure do |cfg|
      cfg.app_id = $cfg['APP_ID']
      cfg.app_secret = $cfg['APP_SECRET']
      cfg.redirect_uri = 'http://api.vkontakte.ru/blank.html'
    end

    system  "#{BROWSER} \"#{VkontakteApi.authorization_url(type: :client, scope: [:audio])}\" >/dev/null &" if !@token
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

    max = @sound.length 
    es ROOT
    i=0
    @sound.each do |snd|
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
end
