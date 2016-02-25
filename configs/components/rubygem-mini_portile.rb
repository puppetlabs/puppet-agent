component "rubygem-mini_portile" do |pkg, settings, platform|
  pkg.version "0.6.2"
  pkg.md5sum "281cc0d974d3810d1195ad4a863ba5b6"
  pkg.url "http://buildsources.delivery.puppetlabs.net/mini_portile-#{pkg.get_version}.gem"

  pkg.build_requires "ruby"

  # Because we are cross-compiling on ppc, we can't use the rubygems we just built.
  # Instead we use the host gem installation and override GEM_HOME. Yay?
  pkg.environment "GEM_HOME" => settings[:gem_home]

  pkg.install do
    ["#{settings[:gem_install]} mini_portile-#{pkg.get_version}.gem"]
  end
end
