component "rubygem-ffi" do |pkg, settings, platform|
  pkg.version "1.9.6"
  pkg.md5sum "8606c263037322ae957e1959245841be"
  pkg.url "http://buildsources.delivery.puppetlabs.net/ffi-#{pkg.get_version}.gem"

  pkg.build_requires "ruby"
  if platform.is_sles? and platform.os_version == '10'
    # The version of make on SLES 10 is too old to work with gem install ffi,
    # so we built our own new one
    pkg.build_requires "pl-make"
  end

  pkg.install do
    [ "export PATH=/opt/pl-build-tools/bin:$$PATH",
      "#{settings[:bindir]}/gem install --no-rdoc --no-ri ffi-#{pkg.get_version}.gem"]
  end
end
