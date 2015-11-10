component "rubygem-net-netconf" do |pkg, settings, platform|
  pkg.version "0.4.3"
  pkg.md5sum "fa173b0965766a427d8692f6b31c85a4"
  pkg.url "http://buildsources.delivery.puppetlabs.net/net-netconf-#{pkg.get_version}.gem"

  pkg.build_requires "ruby"
  pkg.build_requires "rubygem-nokogiri"

  # Because we are cross-compiling on ppc, we can't use the rubygems we just built.
  # Instead we use the host gem installation and override GEM_HOME. Yay?
  pkg.environment "GEM_HOME" => settings[:gem_home]

  pkg.install do
    ["#{settings[:gem_install]} net-netconf-#{pkg.get_version}.gem"]
  end
end
