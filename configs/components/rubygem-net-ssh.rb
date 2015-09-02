component "rubygem-net-ssh" do |pkg, settings, platform|
  pkg.version "2.1.4"
  pkg.md5sum "797c9a7a9e25c781cbf6b77a0054bb2e"
  pkg.url "http://buildsources.delivery.puppetlabs.net/net-ssh-#{pkg.get_version}.gem"

  pkg.replaces 'pe-rubygem-net-ssh'

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
    ["#{gem} install --no-rdoc --no-ri --local net-ssh-#{pkg.get_version}.gem"]
  end
end
