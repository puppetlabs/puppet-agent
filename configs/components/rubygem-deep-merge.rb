component "rubygem-deep-merge" do |pkg, settings, platform|
  pkg.version "1.0.1"
  pkg.md5sum "6f30bc4727f1833410f6a508304ab3c1"
  pkg.url "http://buildsources.delivery.puppetlabs.net/deep_merge-#{pkg.get_version}.gem"

  pkg.replaces "pe-rubygem-deep-merge"

  pkg.build_requires "ruby"

  # Because we are cross-compiling on sparc, we can't use the rubygems we just built.
  # Instead we use the host gem installation and override GEM_HOME. Yay?
  pkg.environment "GEM_HOME" => settings[:gem_home]

  pkg.install do
    ["#{settings[:gem_install]} deep_merge-#{pkg.get_version}.gem"]
  end
end
