component "rubygem-hocon" do |pkg, settings, platform|
  pkg.version "0.9.0"
  pkg.md5sum "0e7817e5d8ebcc6c92b125fe638a1f9d"
  pkg.url "http://buildsources.delivery.puppetlabs.net/hocon-#{pkg.get_version}.gem"

  pkg.build_requires "ruby"

  pkg.install do
    ["#{settings[:bindir]}/gem install --no-rdoc --no-ri --local hocon-#{pkg.get_version}.gem"]
  end
end
