component "ruby-2.4.1" do |pkg, settings, platform|
  pkg.version "2.4.1"
  pkg.md5sum "782bca562e474dd25956dd0017d92677"
  pkg.url "https://cache.ruby-lang.org/pub/ruby/2.4/ruby-#{pkg.get_version}.tar.gz"
  pkg.mirror "http://buildsources.delivery.puppetlabs.net/ruby-#{pkg.get_version}.tar.gz"

  if platform.is_windows?
    pkg.add_source "http://buildsources.delivery.puppetlabs.net/windows/elevate/elevate.exe", sum: "bd81807a5c13da32dd2a7157f66fa55d"
    pkg.add_source "file://resources/files/windows/elevate.exe.config", sum: "a5aecf3f7335fa1250a0f691d754d561"
    pkg.add_source "file://resources/files/ruby_241/windows_ruby_gem_wrapper.bat"
  end

  pkg.replaces 'pe-ruby'
  pkg.replaces 'pe-ruby-mysql'
  pkg.replaces 'pe-rubygems'
  pkg.replaces 'pe-libyaml'
  pkg.replaces 'pe-libldap'
  pkg.replaces 'pe-ruby-ldap'
  pkg.replaces 'pe-rubygem-gem2rpm'

  base = 'resources/patches/ruby_241'

  # These are a pretty smelly hack, and they run the risk of letting tests
  # based on the generated data (that should otherwise fail) pass
  # erroneously. We should probably fix the "not shipping our compiler"
  # problem that led us to do this sooner rather than later.
  #   Ryan McKern, 26/09/2015
  #   Reference notes:
  #   - 6b089ed2: Provide a sane rbconfig for AIX
  #   - 8e88a51a: (RE-5401) Add rbconfig for solaris 11 sparc
  #   - 8f10f5f8: (RE-5400) Roll rbconfig for solaris 11 back to 2.1.6
  #   - 741d18b1: (RE-5400) Update ruby for solaris 11 i386
  #   - d09ed06f: (RE-5290) Update ruby to replace rbconfig for all solaris
  #   - bba35c1e: (RE-5290) Update ruby for a cross-compile on solaris 10
  rbconfig_info = {
    'powerpc-ibm-aix5.3.0.0' => {
      :sum => "7a53afc1c192517c4d6ab1864c8b4a39",
      :target_double => "powerpc-aix5.3.0.0",
    },
    'powerpc-ibm-aix6.1.0.0' => {
      :sum => "dd3232f385602b45bdbf5e60128d8a19",
      :target_double => "powerpc-aix6.1.0.0",
    },
    'powerpc-ibm-aix7.1.0.0' => {
      :sum => "5ba750ff904c51104d9eb33716370b84",
      :target_double => "powerpc-aix7.1.0.0",
     },
    'powerpc-linux-gnu' => {
      :sum => "2f942f5500de901e2c42fc8a9b23d30d",
      :target_double => "powerpc-linux",
    },
    'ppc64le-redhat-linux' => {
      :sum => "75f856df15c48c50514c803947f60bf9",
      :target_double => "powerpc64le-linux",
    },
    'powerpc64le-suse-linux' => {
      :sum => "00247ac1d0a9e59b1fcfb72025e7d628",
      :target_double => "powerpc64le-linux",
    },
    'powerpc64le-linux-gnu' => {
      :sum => "55e9426a06726f2baa82cc561f073fbf",
      :target_double => "powerpc64le-linux",
    },
    's390x-linux-gnu' => {
      :sum => "cbcf3d927bf69b15deb7a7555efdc04e",
      :target_double => "s390x-linux",
    },
    'i386-pc-solaris2.10' => {
      :sum => "a3c043187b645c315aff56dadf996570",
      :target_double => 'i386-solaris2.10',
    },
    'sparc-sun-solaris2.10' => {
      :sum => "72b7fdb633be6d3a6f611bc57ad8bc82",
      :target_double => 'sparc-solaris2.10',
    },
    'i386-pc-solaris2.11' => {
      :sum => "7adedea72967ffae053ac8930f153e64",
      :target_double => 'i386-solaris2.11',
    },
    'sparc-sun-solaris2.11' => {
      :sum => "89956d3af3481972c20f250b56e527e7",
      :target_double => 'sparc-solaris2.11',
    },
    'arm-linux-gnueabihf' => {
      :target_double => 'arm-linux-eabihf'
    },
    'arm-linux-gnueabi' => {
      :target_double => 'arm-linux-eabi'
    },
    'x86_64-w64-mingw32' => {
      :sum => "a93cbbeebb5f30ddf3e40de653f42ac9",
      :target_double => 'x64-mingw32',
    },
    'i686-w64-mingw32' => {
      :sum => "07d789921e433dd7afdeb46a5d22d1f5",
      :target_double => 'i386-mingw32',
    },
  }

  special_flags = " --prefix=#{settings[:prefix]} --with-opt-dir=#{settings[:prefix]} "


  if platform.is_aix?
    pkg.apply_patch "#{base}/aix_ruby_2.1_libpath_with_opt_dir.patch"
    pkg.apply_patch "#{base}/aix_ruby_2.1_fix_make_test_failure.patch"
    pkg.environment "CC", "/opt/pl-build-tools/bin/gcc"
    pkg.environment "LDFLAGS", settings[:ldflags]
    pkg.build_requires "libedit"
    pkg.build_requires "runtime"

    # This normalizes the build string to something like AIX 7.1.0.0 rather
    # than AIX 7.1.0.2 or something
    special_flags += " --build=#{settings[:platform_triple]} "
  end

  if platform.is_windows?
    pkg.apply_patch "#{base}/windows_fixup_generated_batch_files.patch"
    pkg.apply_patch "#{base}/update_rbinstall_for_windows.patch"
    pkg.apply_patch "#{base}/PA-1124_add_nano_server_com_support-8feb9779182bd4285f3881029fe850dac188c1ac.patch"
  end


  # Cross-compiles require a hand-built rbconfig from the target system as does Solaris, AIX and Windies
  if platform.is_cross_compiled_linux? || platform.is_solaris? || platform.is_aix? || platform.is_windows?
    pkg.add_source "file://resources/files/ruby_241/rbconfig/rbconfig-#{settings[:platform_triple]}.rb"
    pkg.build_requires 'runtime' if platform.is_cross_compiled_linux?
  end

  pkg.build_requires "openssl"

  if platform.is_deb?
    pkg.build_requires "zlib1g-dev"
  elsif platform.is_aix?
    pkg.build_requires "http://osmirror.delivery.puppetlabs.net/AIX_MIRROR/zlib-devel-1.2.3-4.aix5.2.ppc.rpm"
  elsif platform.is_rpm?
    pkg.build_requires "zlib-devel"
  elsif platform.is_windows?
    pkg.build_requires "pl-zlib-#{platform.architecture}"
  end

  if platform.is_cross_compiled_linux?
    pkg.build_requires 'pl-ruby'
    special_flags += " --with-baseruby=#{settings[:host_ruby]} "
    pkg.environment "PATH", "#{settings[:bindir]}:$(PATH)"
    pkg.environment "CC", "/opt/pl-build-tools/bin/#{settings[:platform_triple]}-gcc"
    pkg.environment "LDFLAGS", "-Wl,-rpath=/opt/puppetlabs/puppet/lib"
  end

  pkg.environment "optflags", "-O2"

  # The el-4-x86_64, el-5-i386 and sles-10-i386 platforms have issues when using -O3 compiling
  # ruby. This is *possibly* a limitatio of the versions of GCC we have running on those platforms.
  # We should revisit these optimizations once GCC 6.1 is in production for us.
  #
  #         - Sean P. McDonald 07/21/16
  if platform.is_el?
    if platform.os_version == "5" && platform.architecture == "i386"
      pkg.environment "optflags", "-O2"
    elsif platform.os_version == "4" && platform.architecture == "x86_64"
      pkg.environment "optflags", "-O2"
    end
  elsif platform.is_sles? && platform.os_version == "10" && platform.architecture == "i386"
    pkg.environment "optflags", "-O2"
  end

  if platform.is_macos?
    pkg.environment "optflags", settings[:cflags]
  end

  if platform.is_solaris?
    if platform.architecture == "sparc"
      if platform.os_version == "10"
        # ruby1.8 is not new enough to successfully cross-compile ruby 2.1.x (it doesn't understand the --disable-gems flag)
        pkg.build_requires 'ruby20'
      elsif platform.os_version == "11"
        pkg.build_requires 'pl-ruby'
      end

      # During Ruby 2.3.3's configure step on a cross-compiled host, the system cannot
      # determine whether recvmsg requires peek when closing fds, so we must set it
      # manually. Without this, we were getting builds missing the socket library (PA-544).
      special_flags += " --with-baseruby=#{settings[:host_ruby]} --enable-close-fds-by-recvmsg-with-peek "
    end
    pkg.build_requires 'libedit'
    pkg.build_requires 'runtime'
    pkg.environment "PATH", "#{settings[:bindir]}:/usr/ccs/bin:/usr/sfw/bin:$(PATH):/opt/csw/bin"
    pkg.environment "CC", "/opt/pl-build-tools/bin/#{settings[:platform_triple]}-gcc"
    pkg.environment "LDFLAGS", "-Wl,-rpath=/opt/puppetlabs/puppet/lib"
  end

  if platform.is_windows?
    pkg.build_requires "pl-gdbm-#{platform.architecture}"
    pkg.build_requires "pl-iconv-#{platform.architecture}"
    pkg.build_requires "pl-libffi-#{platform.architecture}"
    pkg.build_requires "pl-pdcurses-#{platform.architecture}"

    pkg.environment "PATH", "$(shell cygpath -u #{settings[:gcc_bindir]}):$(shell cygpath -u #{settings[:tools_root]}/bin):$(shell cygpath -u #{settings[:tools_root]}/include):$(shell cygpath -u #{settings[:bindir]}):$(shell cygpath -u #{settings[:ruby_bindir]}):$(shell cygpath -u #{settings[:includedir]}):$(PATH)"
    pkg.environment "CYGWIN", settings[:cygwin]
    pkg.environment "optflags", settings[:cflags] + " -O3"
    pkg.environment "LDFLAGS", settings[:ldflags]

    special_flags = " CPPFLAGS='-DFD_SETSIZE=2048' debugflags=-g --prefix=#{settings[:ruby_dir]} --with-opt-dir=#{settings[:prefix]} "
  end


  # Here we set --enable-bundled-libyaml to ensure that the libyaml included in
  # ruby is used, even if the build system has a copy of libyaml available
  pkg.configure do
    [
      "bash configure \
        --enable-shared \
        --enable-bundled-libyaml \
        --disable-install-doc \
        --disable-install-rdoc \
        #{settings[:host]} \
        #{special_flags}"
     ]
  end

  pkg.build do
    "#{platform[:make]} -j$(shell expr $(shell #{platform[:num_cores]}) + 1)"
  end

  if platform.is_windows?
    pkg.install do
      ["cp ../windows_ruby_gem_wrapper.bat #{settings[:ruby_bindir]}/irb.bat",
       "cp ../windows_ruby_gem_wrapper.bat #{settings[:ruby_bindir]}/gem.bat",
       "cp ../windows_ruby_gem_wrapper.bat #{settings[:ruby_bindir]}/rake.bat",
       "cp ../windows_ruby_gem_wrapper.bat #{settings[:ruby_bindir]}/erb.bat",
       "cp ../windows_ruby_gem_wrapper.bat #{settings[:ruby_bindir]}/rdoc.bat",
       "cp ../windows_ruby_gem_wrapper.bat #{settings[:ruby_bindir]}/ri.bat",]
    end
  end
  pkg.install do
    ["#{platform[:make]} -j$(shell expr $(shell #{platform[:num_cores]}) + 1) install",]
  end

  if platform.is_windows?
    # Elevate.exe is simply used when one of the run_facter.bat or
    # run_puppet.bat files are called. These set up the required environment
    # for the program, and elevate.exe gives the program the elevated
    # privileges it needs to run
    pkg.install_file "../elevate.exe", "#{settings[:windows_tools]}/elevate.exe"
    pkg.install_file "../elevate.exe.config", "#{settings[:windows_tools]}/elevate.exe.config"
    lib_type = platform.architecture == "x64" ? "seh" : "sjlj"

    # As things stand right now, ssl should build under [INSTALLDIR]\Puppet\puppet on
    # windows. However, if things need to run *outside* of the normal batch file runs
    # (puppet.bat ,mco.bat etcc) the location of openssl away from where ruby is
    # installed will cause a failure. Specifically this is meant to help services like
    # mco that require openssl but don't have access to environment.bat. Refer to
    # https://tickets.puppetlabs.com/browse/RE-7593 for details on why this causes
    # failures and why these copies fix that.
    #                   -Sean P. McDonald 07/01/2016
    pkg.install do
      [
        "cp #{settings[:prefix]}/bin/libgcc_s_#{lib_type}-1.dll #{settings[:ruby_bindir]}",
        "cp #{settings[:prefix]}/bin/ssleay32.dll #{settings[:ruby_bindir]}",
        "cp #{settings[:prefix]}/bin/libeay32.dll #{settings[:ruby_bindir]}",
      ]
    end
    pkg.directory settings[:ruby_dir]
  end
  if platform.is_cross_compiled_linux? || platform.is_solaris? || platform.is_aix? || platform.is_windows?
    # Here we replace the rbconfig from our ruby compiled with our toolchain
    # with an rbconfig from a ruby of the same version compiled with the system
    # gcc. Without this, the rbconfig will be looking for a gcc that won't
    # exist on a user system and will also pass flags which may not work on
    # that system.
    # We also disable a safety check in the rbconfig to prevent it from being
    # loaded from a different ruby, because we're going to do that later to
    # install compiled gems.
    #
    # On AIX we build everything using our own GCC. This means that gem
    # installing a compiled gem would not work without us shipping that gcc.
    # This tells the ruby setup that it can use the default system gcc rather
    # than our own.
    target_dir = File.join(settings[:libdir], "ruby", "2.4.0", rbconfig_info[settings[:platform_triple]][:target_double])
    sed = "sed"
    sed = "gsed" if platform.is_solaris?
    sed = "/opt/freeware/bin/sed" if platform.is_aix?
    pkg.install do
      [
        "#{sed} -i 's|raise|warn|g' #{target_dir}/rbconfig.rb",
        "mkdir -p #{settings[:datadir]}/doc",
        "cp #{target_dir}/rbconfig.rb #{settings[:datadir]}/doc",
        "cp ../rbconfig-#{settings[:platform_triple]}.rb #{target_dir}/rbconfig.rb",
      ]
    end
  end
end
