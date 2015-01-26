component "rubygem-ffi" do |pkg, settings, platform|
  pkg.version "1.9.6"
  pkg.md5sum "8606c263037322ae957e1959245841be"
  pkg.url "http://buildsources.delivery.puppetlabs.net/ffi-#{pkg.get_version}.gem"

  pkg.build_requires "ruby"

  pkg.install do
    ["#{settings[:bindir]}/gem install --no-rdoc --no-ri ffi-#{pkg.get_version}.gem"]
  end
end
