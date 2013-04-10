Gem::Specification.new do |s|
  s.name = 'vkdl'
  s.version = '1.0.2'
  s.date = '2013-04-07'
  s.executables << 'vkdl'
  s.executables << 'vkdl-init'
  s.summary = 'private'
  s.description = ''
  s.authors = ['Alexander Smirnov aka JelF']
  s.email = 'overseer@blizzard.gg'
  s.files = Dir['{bin,lib,etc}/**/*', 'README*', 'LICENSE*'] & `git ls-files -z`.split("\0")
  s.homepage = 'http://blank.com'
end
