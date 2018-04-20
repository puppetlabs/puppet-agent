require 'erb'

template = ARGV[0]
gemdir = ARGV[1]
suffix = ARGV[2]

facter_version = File.read("#{gemdir}/ext/facter/facter/CMakeLists.txt")
                   .match(/project\(FACTER VERSION [\d\.]*\)/)
                   .to_s
                   .gsub(/[^\d\.]/, "")
facter_version += suffix

gemspec = ERB.new(File.read(template))
outfile = template.gsub('.erb', '')
File.open("#{gemdir}/#{outfile}", 'w') do |out|
  out.write(gemspec.result(binding))
end
