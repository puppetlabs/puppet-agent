component "rubygem-nokogiri" do |pkg, settings, platform|
  pkg.version "1.6.6.2"
  pkg.md5sum "fc9f91534bf93d57b84f625b55732a7c"
  pkg.url "http://buildsources.delivery.puppetlabs.net/nokogiri-#{pkg.get_version}.gem"

  pkg.build_requires "ruby"
  pkg.build_requires "rubygem-mini_portile"

  # Because we are cross-compiling on ppc, we can't use the rubygems we just built.
  # Instead we use the host gem installation and override GEM_HOME. Yay?
  pkg.environment "GEM_HOME" => settings[:gem_home]

  pkg.install do
    ["#{settings[:gem_install]} nokogiri-#{pkg.get_version}.gem -- --use-system-libraries --with-xml2-lib=/opt/puppetlabs/puppet/lib --with-xml2-include=/opt/puppetlabs/puppet/include/libxml2 --with-xslt-lib=/opt/puppetlabs/puppet/lib --with-xslt-include=/opt/puppetlabs/puppet/include/libxslt"]
  end
end
