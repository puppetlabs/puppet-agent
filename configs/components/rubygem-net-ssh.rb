component "rubygem-net-ssh" do |pkg, settings, platform|
  pkg.version "2.1.4"
  pkg.md5sum "797c9a7a9e25c781cbf6b77a0054bb2e"
  pkg.url "http://buildsources.delivery.puppetlabs.net/net-ssh-#{pkg.get_version}.gem"

  pkg.replaces 'pe-rubygem-net-ssh'

  pkg.build_requires "ruby"

  # Because we are cross-compiling on sparc, we can't use the rubygems we just built.
  # Instead we use the host gem installation and override GEM_HOME. Yay?
  pkg.environment "GEM_HOME" => settings[:gem_home]

  pkg.install do
    ["#{settings[:gem_install]} net-ssh-#{pkg.get_version}.gem"]
  end
end
