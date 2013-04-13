$LOAD_PATH << './lib'
require 'namer'
require 'cfg'
require 'pathname'

class Downloader
  attr_accessor :queue

  MAX_THREADS    = 5 #beter way lookup config
  MAX_DL_THREADS = 1

  def self.es(path)
    path.mkdir if !path.exist?
  end

  def initialize (namer, audios)
    @namer = namer
    @namer_threads = []
    @dl_threads    = []
    @queue         = []
    @queue_mutex   = Mutex.new
    @audios        = audios
    @namer_finished= false
    
    @audios_passed = 0 #syncronizes with queue_mutex
    @audios_downloaded = 0
    @audios_downloaded_mutex = Mutex.new
    @max_audios    = audios.length

    @ROOT = Pathname.new $cfg['ROOT']
    @WGET = $cfg['WGET']

    @ROOT.mkpath
  end
  def new_namer_thread(audio)
    thread = Thread.new do
      res = (@namer.lookup2 audio) << audio.url
      @queue_mutex.synchronize do
        @queue << res
        @audios_passed += 1
      end
    end
    thread
  end
  def namer_thread_manager
    while(!@audios.empty?) do
      @namer_threads=@namer_threads.find_all {|t| t.alive?}      
      if (@namer_threads.length < MAX_THREADS)
        @namer_threads << new_namer_thread(@audios.shift)
      else 
        sleep 0.01
      end
    end
    while(!@namer_threads.empty?) do
      @namer_threads.pop.join
    end
    @namer_finished = true
  end
  def new_wget_thread(queued)
    thread = Thread.new do
      (folder,title,url) = queued
      folder = @ROOT+folder
      Downloader.es folder
      `#{@WGET} -c -O "#{(folder+title).to_path}.mp3" #{url}`
      @audios_downloaded_mutex.synchronize do
        @audios_downloaded += 1
      end
    end
    thread 
  end
  def wget_thread_manager
    while(!@namer_finished or !@queue.empty?) do
      @dl_threads=@dl_threads.find_all {|t| t.alive?}      
      if ((@dl_threads.length < MAX_DL_THREADS) && !queue.empty?)
        @queue_mutex.synchronize do 
          @ntpar = queue.shift
        end
        @dl_threads << new_wget_thread(@ntpar)
      else 
        sleep 0.01
      end
    end
    while(!@dl_threads.empty?) do
      @dl_threads.pop.join
    end
  end
  def start
    que = Thread.new { namer_thread_manager }
    dle = Thread.new {  wget_thread_manager }
    while( que.status || dle.status ) do
      puts "\nPassed:  #{@audios_passed}(#{@audios_passed*100/@max_audios}%), Downloaded: #{@audios_downloaded}(#{@audios_downloaded*100/@max_audios}%), Total: #{@max_audios}"
      sleep 1
    end
    p que.status
    p dle.status
  end
end
