component "facter-source-gem" do |pkg, settings, platform|
  pkg.build_requires 'facter-source'
  pkg.build_requires 'leatherman-source'
  pkg.build_requires 'cpp-hocon-source'
  pkg.build_requires 'puppet-runtime'

  pkg.add_source("file://resources/files/facter-gem/facter-source.gemspec.erb", erb: 'true')
  pkg.add_source("file://resources/files/facter-gem/extconf.rb")
  pkg.add_source("file://resources/files/facter-gem/Makefile.erb")
  pkg.install_file('facter-source.gemspec', "#{settings[:gemdir]}")
  pkg.install_file('extconf.rb', "#{settings[:gemdir]}/ext/facter")
  pkg.install_file('Makefile.erb', "#{settings[:gemdir]}/ext/facter")

  pkg.install do
    [
      "pushd #{settings[:gemdir]}",
      "#{settings[:gem_binary]} build facter-source.gemspec",
      "popd"
    ]
  end
end
