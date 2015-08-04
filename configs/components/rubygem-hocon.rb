component "rubygem-hocon" do |pkg, settings, platform|
  pkg.version "0.9.3"
  pkg.md5sum "af89595899c3b893787045039ff02ee0"
  pkg.url "http://buildsources.delivery.puppetlabs.net/hocon-#{pkg.get_version}.gem"

  pkg.build_requires "ruby"

  pkg.install do
    ["#{settings[:bindir]}/gem install --no-rdoc --no-ri --local hocon-#{pkg.get_version}.gem"]
  end
end
