component 'libedit' do |pkg, settings, platform|
  pkg.version '20150325-3.1'
  pkg.md5sum '43cdb5df3061d78b5e9d59109871b4f6'
  pkg.url "http://buildsources.delivery.puppetlabs.net/libedit-20150325-3.1.tar.gz"

  pkg.environment "PATH" => "/opt/pl-build-tools/bin:$$PATH"

  if platform.is_solaris?
    pkg.environment "CC" => "/opt/pl-build-tools/bin/i386-pc-solaris2.10-gcc"
  end

  pkg.configure do
    "./configure --prefix=#{settings[:prefix]}"
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
