component 'libedit' do |pkg, settings, platform|
  pkg.version '20150325-3.1'
  pkg.md5sum '43cdb5df3061d78b5e9d59109871b4f6'
  pkg.url "http://thrysoee.dk/editline/libedit-#{pkg.get_version}.tar.gz"

  if platform.is_solaris?
    pkg.environment "CC", "/opt/pl-build-tools/bin/#{settings[:platform_triple]}-gcc"
  elsif platform.is_aix?
    pkg.build_requires "http://osmirror.delivery.puppetlabs.net/AIX_MIRROR/gawk-3.1.3-1.aix5.1.ppc.rpm"
    pkg.environment "CC", "/opt/pl-build-tools/bin/gcc"
    pkg.environment "LDFLAGS", settings[:ldflags]
  end

  if platform.is_macos?
    pkg.environment "CFLAGS", settings[:cflags]
  end

  pkg.configure do
    "bash configure --enable-shared --prefix=#{settings[:prefix]} #{settings[:host]}"
  end

  pkg.build do
    "#{platform[:make]} -j$(shell expr $(shell #{platform[:num_cores]}) + 1)"
  end

  pkg.install do
    "#{platform[:make]} -j$(shell expr $(shell #{platform[:num_cores]}) + 1) install"
  end

  pkg.link File.join(settings[:libdir], 'libedit.so'), File.join(settings[:libdir], 'libreadline.so')
  pkg.link File.join(settings[:includedir], 'editline', 'readline.h'), File.join(settings[:includedir], 'readline', 'readline.h')
  pkg.link File.join(settings[:includedir], 'editline', 'readline.h'), File.join(settings[:includedir], 'readline', 'history.h')
end
