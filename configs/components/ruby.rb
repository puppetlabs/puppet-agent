component "ruby" do |comp, settings, platform|
  comp.version = "1.9.3-p484"
  comp.md5sum = "8ac0dee72fe12d75c8b2d0ef5d0c2968"
  comp.url = "http://buildsources.delivery.puppetlabs.net/ruby-1.9.3-p484.tar.gz"

  comp.depends_on "openssl"
  comp.depends_on "libyaml"

=begin
# Make this magic. if there is a component, use it. if not, add it as a runtime dependency.
  if platform.is_deb?
    comp.depends_on "zlib1g"
  elsif platform.is_rpm?
    comp.depends_on "zlib"
  end

=end

  if platform.is_deb?
#    case platform.version
#    when 5
#      # everything is awesome
#    when 4
#      # quit now, everything is awful
#    else
#
#    end
    comp.build_depends_on "zlib1g-dev"
  elsif platform.is_rpm?
    comp.build_depends_on "zlib-devel"
  end

  comp.configure_with do
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

  comp.build_with do
    ["#{platform[:make]}"]
  end

  comp.install_with do
    ["#{platform[:make]} install"]
  end
end
