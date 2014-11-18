if platform.name =~ /^el-(5|6|7)-.*/
  component "ruby-selinux" do |pkg, settings, platform|
    if platform.name =~ /^el-5-.*$/
      pkg.version "1.33.4"
      pkg.md5sum "08762379de2242926854080dad649b67"
      pkg.apply_patch "resources/patches/ruby-selinux/libselinux-rhat.patch"
    else
      pkg.version "2.0.94"
      pkg.md5sum "f814c71fca5a85ebfeb81b57afed59db"
    end

    pkg.url "http://buildsources.delivery.puppetlabs.net/libselinux-#{pkg.get_version}.tgz"

    pkg.depends_on "ruby"

    pkg.build_depends_on "swig"
    pkg.build_depends_on "libsepol"
    pkg.build_depends_on "libsepol-devel"
    pkg.build_depends_on "libselinux-devel"

    pkg.build do
      ["export RUBYHDRDIR=$(shell #{settings[:bindir]}/ruby -rrbconfig -e 'puts RbConfig::CONFIG[\"rubyhdrdir\"]')",
       "export VENDORARCHDIR=$(shell #{settings[:bindir]}/ruby -rrbconfig -e 'puts RbConfig::CONFIG[\"vendorarchdir\"]')",
       "export ARCHDIR=$${RUBYHDRDIR}/$(shell #{settings[:bindir]}/ruby -rrbconfig -e 'puts RbConfig::CONFIG[\"arch\"]')",
       "export INCLUDESTR=\"-I#{settings[:includedir]} -I$${RUBYHDRDIR} -I$${ARCHDIR}\"",
       "cp -pr src/{selinuxswig_ruby.i,selinuxswig.i}  .",
       "swig -Wall -ruby  -I../include -I/usr/include -o selinuxswig_ruby_wrap.c -outdir ./ selinuxswig_ruby.i",
       "gcc $${INCLUDESTR}  -I../include -I/usr/include -D_GNU_SOURCE -D_FILE_OFFSET_BITS=64 -fPIC -DSHARED -c -o selinuxswig_ruby_wrap.lo selinuxswig_ruby_wrap.c",
       "gcc $${INCLUDESTR}  -I../include -I/usr/include -D_GNU_SOURCE -D_FILE_OFFSET_BITS=64   -shared -o _rubyselinux.so selinuxswig_ruby_wrap.lo -lselinux -L/usr/lib -Wl,-soname,_rubyselinux.so"]
    end

    pkg.install do
      ["export VENDORARCHDIR=$(shell #{settings[:bindir]}/ruby -rrbconfig -e 'puts RbConfig::CONFIG[\"vendorarchdir\"]')",
       "install -d $${VENDORARCHDIR}",
       "install -p -m755 _rubyselinux.so $${VENDORARCHDIR}/selinux.so"]
    end
  end
end
