component "rubygem-nats-pure" do |pkg, settings, platform|
  pkg.version "0.2.4"
  pkg.md5sum "209d12d8a9b6be556e2748b0a243eb5d"
  pkg.url "https://rubygems.org/downloads/nats-pure-#{pkg.get_version}.gem"

  pkg.build_requires "ruby-#{settings[:ruby_version]}"
  pkg.environment "GEM_HOME" => settings[:gem_home]
  pkg.environment "RUBYLIB" => "#{settings[:ruby_vendordir]}:$$RUBYLIB"

  pkg.install do
    ["#{settings[:gem_install]} nats-pure-#{pkg.get_version}.gem"]
  end
end
