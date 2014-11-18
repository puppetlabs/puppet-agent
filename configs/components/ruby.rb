component "ruby" do |comp, settings, platform|
  comp.version "1.9.3-p484"
  comp.md5sum "8ac0dee72fe12d75c8b2d0ef5d0c2968"
  comp.url "http://buildsources.delivery.puppetlabs.net/ruby-1.9.3-p484.tar.gz"

  comp.depends_on "openssl"
  comp.depends_on "libyaml"

  if platform.is_deb?
    comp.build_depends_on "zlib1g-dev"
  elsif platform.is_rpm?
    comp.build_depends_on "zlib-devel"
  end

  comp.configure do
    ["./configure \
                --prefix=#{settings[:prefix]} \
                --with-opt-dir=#{settings[:prefix]} \
                --enable-option-checking=no \
                --with-openssl-dir=#{settings[:prefix]} \
                --without-win32ole \
                --without-tcl \
                --without-gcc \
                --without-tk \
                --without-fiddle \
                --without-X11 \
                --disable-pthread \
                --disable-install-rdoc \
                --disable-dtrace"]
  end

  comp.build do
    ["#{platform[:make]}"]
  end

  comp.install do
    ["#{platform[:make]} install"]
  end
end
