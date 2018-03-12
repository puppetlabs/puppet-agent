component "rubygem-multi_json" do |pkg, settings, platform|
  pkg.version "1.13.1"
  pkg.md5sum "b7702a827fd011461fbda6b80f2219d5"
  pkg.url "https://rubygems.org/downloads/multi_json-#{pkg.get_version}.gem"
  pkg.mirror "#{settings[:buildsources_url]}/multi_json-#{pkg.get_version}.gem"

  pkg.build_requires "ruby-#{settings[:ruby_version]}"

  # Install into the directory for gems shared by puppet and puppetserver
  pkg.environment "GEM_HOME", settings[:puppet_gem_vendor_dir]

  # PA-25 in order to install gems in a cross-compiled environment we need to
  # set RUBYLIB to include puppet and hiera, so that their gemspecs can resolve
  # hiera/version and puppet/version requires. Without this the gem install
  # will fail by blowing out the stack.
  pkg.environment "RUBYLIB", "#{settings[:ruby_vendordir]}:$(RUBYLIB)"

  pkg.install do
    ["#{settings[:gem_install]} multi_json-#{pkg.get_version}.gem"]
  end
end
