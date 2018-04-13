component "facter-source-gem" do |pkg, settings, platform|
  pkg.build_requires 'facter-source'
  pkg.build_requires 'leatherman-source'
  pkg.build_requires 'cpp-hocon-source'
  pkg.build_requires 'puppet-runtime'

  pkg.add_source("file://resources/files/facter-gem/facter-source.gemspec.erb")
  pkg.add_source("file://resources/files/facter-gem/extconf.rb")
  pkg.add_source("file://resources/files/facter-gem/Makefile.erb")
  pkg.add_source("file://resources/files/facter-gem/generate-gemspec.rb")
  pkg.install_file('extconf.rb', "#{settings[:gemdir]}/ext/facter")
  pkg.install_file('Makefile.erb', "#{settings[:gemdir]}/ext/facter")

  pkg.configure do
    [
      "#{settings[:ruby_binary]} generate-gemspec.rb facter-source.gemspec.erb '#{settings[:gemdir]}' '#{settings[:project_version]}'"
    ]
  end

  pkg.install do
    [
      "pushd #{settings[:gemdir]}",
      "#{settings[:gem_binary]} build facter-source.gemspec",
      "popd"
    ]
  end
end
