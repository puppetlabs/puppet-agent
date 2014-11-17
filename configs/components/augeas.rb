component "augeas" do |pkg, settings, platform|
  pkg.version = "1.2.0"
  pkg.md5sum = "dce2f52cbd20f72c7da48e014ad48076"
  pkg.url = "http://buildsources.delivery.puppetlabs.net/augeas-1.2.0.tar.gz"

  if platform.is_rpm?
    pkg.build_depends_on "libxml2-devel"
    pkg.build_depends_on "readline-devel"
  elsif platform.is_deb?
    pkg.build_depends_on "libxml2-dev"
    pkg.build_depends_on "libreadline-dev"
  end

  pkg.configure_with do
    ["./configure --prefix=#{settings[:prefix]}"]
  end

  pkg.build_with do
    ["#{platform[:make]}"]
  end

  pkg.install_with do
    ["#{platform[:make]} install"]
  end
end
