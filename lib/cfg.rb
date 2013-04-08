require 'json'
require 'pathname'

$CFG_FILE_PATH = Pathname.new '~/.config/vkdl.json'

if not $CFG_FILE_PATH.exist?
  `cp etc/default_cfg.json #{$CFG_FILE_PATH.to_path}`
end

cfg_file = File.new($CFG_FILE_PATH.expand_path,'r')

$cfg = JSON.parse(cfg_file.read)
