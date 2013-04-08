#!/usr/bin/env ruby 
# encoding: utf-8

require 'vkontakte_api'
#require 'peach'
require 'pathname'
WGET = '/usr/bin/wget'

VkontakteApi.configure do |cfg|
  cfg.app_id = '3551558'
  cfg.app_secret = 'mTxQUdtN8hXNPfEPEMWL'
  cfg.redirect_uri = 'http://api.vkontakte.ru/blank.html'
end


system  'chromium -w "'+VkontakteApi.authorization_url(type: :client, scope: [:audio]) + '">/dev/null &'
STDERR.print "enter token:\t"
TOKEN = STDIN.gets.split("\n").first 
@vk = VkontakteApi::Client.new TOKEN

sound = @vk.audio.get
MAX = sound.length 
def es(path)
  path.mkdir if !path.exist?
end

def prp(str)
  str.gsub!(/[^0-9a-zA-Zа-яА-Я\s\-]/,'_')
  str.gsub!(/(\s)$/,'_')
  str
end

ROOT=Pathname.new '/run/media/jelf/000B-ACC0/music'
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
  print "#{i}/#{MAX}\n"
end
