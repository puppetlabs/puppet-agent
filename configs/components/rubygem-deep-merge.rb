component "rubygem-deep-merge" do |pkg, settings, platform|
  pkg.version "1.0.1"
  pkg.md5sum "6f30bc4727f1833410f6a508304ab3c1"
  pkg.url "http://buildsources.delivery.puppetlabs.net/deep_merge-#{pkg.get_version}.gem"

  pkg.build_requires "ruby"

  pkg.install do
    ["#{settings[:bindir]}/gem install --no-rdoc --no-ri --local deep_merge-#{pkg.get_version}.gem"]
  end
end
