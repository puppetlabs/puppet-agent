component "rubygem-deep-merge" do |pkg, settings, platform|
  pkg.version "1.0.0"
  pkg.md5sum "4bff008be5605bd6fb687a6e33c028e0"
  pkg.url "http://buildsources.delivery.puppetlabs.net/deep_merge-1.0.0.gem"

  pkg.provides "pe-#{pkg.get_name}", pkg.get_version
  pkg.replaces "pe-#{pkg.get_name}", '1.0.1'

  pkg.build_requires "ruby"

  pkg.install do
    ["#{settings[:bindir]}/gem install --no-rdoc --no-ri --local deep_merge-1.0.0.gem"]
  end
end
