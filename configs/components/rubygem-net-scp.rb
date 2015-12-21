component "rubygem-net-scp" do |pkg, settings, platform|
  pkg.version "1.2.1"
  pkg.md5sum "abeec1cab9696e02069e74bd3eac8a1b"
  pkg.url "http://buildsources.delivery.puppetlabs.net/net-scp-#{pkg.get_version}.gem"

  pkg.build_requires "ruby"
  pkg.build_requires "rubygem-net-ssh"

  # Because we are cross-compiling, we can't use the rubygems we just built.
  # Instead we use the host gem installation and override GEM_HOME. Yay?
  pkg.environment "GEM_HOME" => settings[:gem_home]

  pkg.install do
    ["#{settings[:gem_install]} net-scp-#{pkg.get_version}.gem"]
  end
end
