# encode: utf-8
$LOAD_PATH << './lib'
require 'pathname'
require 'cfg.rb'
require 'json'
require 'sqlite3'

class Namer
  def setup
    if not @db_file_path.exist?
      `cp etc/dictionary.db #{@db_file_path.to_path}`
    end
  end
  def initialize (root)
    @primary_regexp = Regexp.new($cfg['NAMER']['PRIMARY_REGEXP'],nil,'u')

    @db_file_path=(Pathname.new $cfg['NAMER']['DICTIONARY_DB']).expand_path
    @db_file_path=root + @db_file_path if @db_file_path.relative?

    setup

    @db = SQLite3::Database.new(@db_file_path.to_s)
  end

  def dbread(str)
    res=@db.execute %q{SELECT dictionary.value FROM dictionary WHERE dictionary.key=?},str
    if res.empty?
      str
    else res.first.first
    end
  end
   

  def lookup (str)
    str.gsub!(@primary_regexp,'_')
    str.gsub!(/(\s)$/,'')
    dbread str 
  end
  
  def lookup2 (audio)
    artist = lookup audio['artist']
    title  = lookup audio['title']
    [artist,title]
  end

  #THERE IS A LOT OF CONSTANTS
  HASHCUP = 2**16 #raising removes collisions (we need collisions!)
  LENCUP  = 4    #don't even care if rhere is more then 8 words
  SHIFT   = 2**(64/LENCUP)
  def self.superhash str 
    words = str.split /\s/ #Configurable regexp
    baselen = 64 - (64/LENCUP)*words.length 
    words.map!{|s| s.hash%HASHCUP} 
    sh = words.inject{|sh,wh| sh*SHIFT+wh}
    sh = sh * 2**baselen
    sh.round
  end
end
