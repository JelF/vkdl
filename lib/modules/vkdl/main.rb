#!/usr/bin/env ruby 
# encoding: utf-8

require 'vkontakte_api'
require 'pathname'

#May breake formating
module Main
  ROOT=Pathname.new '/tmp/lib'
  def self.es(path)
    path.mkdir if !path.exist?
  end

  def self.prp(str)
    str.gsub!(/[^0-9a-zA-Zа-яА-Я\s\-]/,'_')
    str.gsub!(/(\s)$/,'_')
    str
  end

  WGET = '/usr/bin/wget'
  def self.start
    VkontakteApi.configure do |cfg|
      cfg.app_id = '3551558'
      cfg.app_secret = 'mTxQUdtN8hXNPfEPEMWL'
      cfg.redirect_uri = 'http://api.vkontakte.ru/blank.html'
    end

    if !@token
      system  'chromium -w "'+VkontakteApi.authorization_url(type: :client, scope: [:audio]) + '">/dev/null &'
      STDERR.print "enter token:\t"
      @token = STDIN.gets.split("\n").first 
      @vk = VkontakteApi::Client.new @token
    end

    sound = @vk.audio.get
    max = sound.length 
    es ROOT
    i=0
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
end
