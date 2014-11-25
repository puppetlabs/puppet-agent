component "ruby" do |comp, settings, platform|
  comp.version "2.1.5"
  comp.md5sum "df4c1b23f624a50513c7a78cb51a13dc"
  comp.url "http://buildsources.delivery.puppetlabs.net/ruby-2.1.5.tar.gz"

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
