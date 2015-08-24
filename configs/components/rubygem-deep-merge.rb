component "rubygem-deep-merge" do |pkg, settings, platform|
  pkg.version "1.0.1"
  pkg.md5sum "6f30bc4727f1833410f6a508304ab3c1"
  pkg.url "http://buildsources.delivery.puppetlabs.net/deep_merge-#{pkg.get_version}.gem"

  pkg.replaces "pe-rubygem-deep-merge"

  pkg.build_requires "ruby"
  pkg.environment "GEM_HOME" => settings[:gem_home]

  if platform.architecture == "sparc"
    # Because we are cross-compiling on sparc, we can't use the rubygems we just built.
    # Instead we use the host gem installation and override GEM_HOME. Yay?
    gem = "/opt/csw/bin/gem19"
  else
    gem = File.join(settings[:bindir], 'gem')
  end

  pkg.install do
    ["#{gem} install --no-rdoc --no-ri --local deep_merge-#{pkg.get_version}.gem"]
  end
end
