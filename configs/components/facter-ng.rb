component "facter-ng" do |pkg, settings, platform|
  pkg.version '4.0.30'
  pkg.sha256sum '967f30a9834590c46d44701662c0b4bc3bdf7f1f827a7242ca09a29975bd07a3'
  pkg.url "https://github.com/puppetlabs/facter/archive/#{pkg.get_version}.tar.gz"

  pkg.build_requires "puppet-runtime"
  pkg.build_requires "pl-ruby-patch"

  # When cross-compiling, we can't use the rubygems we just built.
  # Instead we use the host gem installation and override GEM_HOME. Yay?
  pkg.environment "GEM_HOME", settings[:gem_home]
  pkg.environment "GEM_PATH", settings[:puppet_gem_vendor_dir]

  # PA-25 in order to install gems in a cross-compiled environment we need to
  # set RUBYLIB to include puppet and hiera, so that their gemspecs can resolve
  # hiera/version and puppet/version requires. Without this the gem install
  # will fail by blowing out the stack.
  if settings[:ruby_vendordir]
    pkg.environment "RUBYLIB", "#{settings[:ruby_vendordir]}:$(RUBYLIB)"
  end


  pkg.configure do
    [
        "cd ..",
        "mv facter-#{pkg.get_version}/* #{pkg.get_version}",
        "cd #{pkg.get_version}"
    ]
  end


  # Remove required_ruby_version from gemspec, this is needed for cross-compiled
  # platforms as ruby version is lower than 2.3 on these platforms.
  if platform.is_cross_compiled?
    sed_pattern = %(s/spec.required_ruby_version = '~> 2.3'/ /)
    pkg.build do
      [
          %(#{platform[:sed]} -ie "#{sed_pattern}" agent/facter-ng.gemspec)
      ]
    end
  end

  pkg.build do
    [
        "#{settings[:host_gem]} build agent/facter-ng.gemspec"
    ]
  end

  if platform.is_windows?
    pkg.add_source("file://resources/files/windows/facter-ng.bat", sum: "1521ec859c1ec981a088de5ebe2b270c")
    pkg.install_file "../facter-ng.bat", "#{settings[:link_bindir]}/facter-ng.bat"
  end

  pkg.install do
    ["#{settings[:gem_install]} #{name}-*.gem"]
  end
end
