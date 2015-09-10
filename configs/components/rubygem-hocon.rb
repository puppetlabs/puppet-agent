component "rubygem-hocon" do |pkg, settings, platform|
  pkg.version "0.9.3"
  pkg.md5sum "af89595899c3b893787045039ff02ee0"
  pkg.url "http://buildsources.delivery.puppetlabs.net/hocon-#{pkg.get_version}.gem"

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
    ["#{gem} install --no-rdoc --no-ri --local hocon-#{pkg.get_version}.gem"]
  end
end
