require 'mkmf'
require 'erb'

cmake_binary = find_executable('cmake')
source_root = File.expand_path("#{__FILE__}/..")
cmake_opts = ENV['FACTER_CMAKE_OPTS']

if RbConfig::CONFIG['arch'].include?('mingw')
  windows_native_source = source_root.gsub('/', '\\')
  # xcopy will make the libdir for us, so there's no mkdir for windows
  install_command = "xcopy \"prefix\\bin\\*facter*\" \"#{windows_native_source}\\..\\..\\lib\" /i"
  touch_command = 'type nul >'
  mkdir_command = 'mkdir'
else
  install_command = "mkdir -p #{source_root}/../../lib && cp prefix/lib/*facter* #{source_root}/../../lib"
  touch_command = 'touch'
  mkdir_command = 'mkdir -p'
end

make_template = File.open(source_root+"/Makefile.erb").read
makefile = ERB.new(make_template).result(binding)
File.write('Makefile', makefile)
