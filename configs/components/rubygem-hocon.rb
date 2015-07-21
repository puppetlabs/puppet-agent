component "rubygem-hocon" do |pkg, settings, platform|
  pkg.version "0.9.2"
  pkg.md5sum "a52cf152dd6efcc943d002f724121fe6"
  pkg.url "http://buildsources.delivery.puppetlabs.net/hocon-#{pkg.get_version}.gem"

  pkg.build_requires "ruby"

  pkg.install do
    ["#{settings[:bindir]}/gem install --no-rdoc --no-ri --local hocon-#{pkg.get_version}.gem"]
  end
end
