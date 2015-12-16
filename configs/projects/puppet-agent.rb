project "puppet-agent" do |proj|
  platform = proj.get_platform

  # Project level settings our components will care about
  # Windows has its own seperate layout
  if platform.is_windows?
    proj.setting(:install_root, "#{platform.drive_root}/ProgramFiles/PuppetLabs")
    proj.setting(:prefix, File.join(proj.install_root, "Puppet"))
    proj.setting(:sysconfdir, "#{platform.drive_root}/ProgramData/PuppetLabs")
    proj.setting(:puppet_configdir, File.join(proj.sysconfdir, 'puppet', 'etc'))
    proj.setting(:puppet_codedir, File.join(proj.sysconfdir, 'code'))
    proj.setting(:bindir, File.join(proj.prefix, "bin"))
    proj.setting(:link_bindir, File.join(proj.prefix, "bin"))

    proj.setting(:logdir, File.join(proj.sysconfdir, "puppet", "var", "log"))
    proj.setting(:piddir, File.join(proj.sysconfdir, "puppet", "var", "run"))
    proj.setting(:libdir, File.join(proj.prefix, "lib"))
    proj.setting(:includedir, File.join(proj.prefix, "include"))
    proj.setting(:datadir, File.join(proj.prefix, "share"))
    proj.setting(:mandir, File.join(proj.datadir, "man"))

    proj.setting(:ruby_prefix, File.join(proj.libdir, "sys", "ruby"))
    proj.setting(:ruby_libdir, File.join(proj.ruby_prefix, "lib"))
    proj.setting(:gem_home, File.join(proj.ruby_libdir, "ruby/gems/2.1.0"))
    proj.setting(:ruby_vendordir, File.join(proj.ruby_libdir, "ruby", "site_ruby"))
    proj.setting(:ruby_bindir, File.join(proj.ruby_prefix, "bin"))
    proj.setting(:host_ruby, File.join(proj.ruby_bindir, "ruby"))
    proj.setting(:host_gem, File.join(proj.ruby_bindir, "gem"))

    proj.setting(:tmpfilesdir, "#{platform.drive_root}/Windows/Temp")
  else
    proj.setting(:install_root, "/opt/puppetlabs")
    proj.setting(:prefix, File.join(proj.install_root, "puppet"))

    if platform.is_eos?
      proj.setting(:sysconfdir, "/persist/sys/etc/puppetlabs")
      proj.setting(:link_sysconfdir, "/etc/puppetlabs")
    elsif platform.is_osx?
      proj.setting(:sysconfdir, "/private/etc/puppetlabs")
    else
      proj.setting(:sysconfdir, "/etc/puppetlabs")
    end

    proj.setting(:puppet_configdir, File.join(proj.sysconfdir, 'puppet'))
    proj.setting(:puppet_codedir, File.join(proj.sysconfdir, 'code'))
    proj.setting(:logdir, "/var/log/puppetlabs")
    proj.setting(:piddir, "/var/run/puppetlabs")
    proj.setting(:bindir, File.join(proj.prefix, "bin"))
    proj.setting(:link_bindir, "/opt/puppetlabs/bin")
    proj.setting(:libdir, File.join(proj.prefix, "lib"))
    proj.setting(:includedir, File.join(proj.prefix, "include"))
    proj.setting(:datadir, File.join(proj.prefix, "share"))
    proj.setting(:mandir, File.join(proj.datadir, "man"))
    proj.setting(:gem_home, File.join(proj.libdir, "ruby/gems/2.1.0"))
    proj.setting(:tmpfilesdir, "/usr/lib/tmpfiles.d")
    proj.setting(:ruby_vendordir, File.join(proj.libdir, "ruby", "vendor_ruby"))
    proj.setting(:host_ruby, File.join(proj.bindir, "ruby"))
    proj.setting(:host_gem, File.join(proj.bindir, "gem"))
  end


  # For solaris, we build cross-compilers
  if platform.is_solaris?
    if platform.architecture == 'i386'
      platform_triple = "#{platform.architecture}-pc-solaris2.#{platform.os_version}"
    else
      platform_triple = "#{platform.architecture}-sun-solaris2.#{platform.os_version}"
      host = "--host #{platform_triple}"

      # For cross-compiling, we have a standalone ruby
      if platform.os_version == "10"
        proj.setting(:host_ruby, "/opt/csw/bin/ruby")
        proj.setting(:host_gem, "/opt/csw/bin/gem19")
      else
        proj.setting(:host_ruby, "/opt/pl-build-tools/bin/ruby")
        proj.setting(:host_gem, "/opt/pl-build-tools/bin/gem")
      end
    end
  elsif platform.is_windows?
    # For windows, we need to ensure we are building for mingw not cygwin
    if platform.architecture == "x64"
      platform_triple = "x86_64-unknown-mingw32"
    else
      platform_triple = "i686-unknown-mingw32"
    end
    host = "--host #{platform_triple}"
  end

  proj.setting(:gem_install, "#{proj.host_gem} install --no-rdoc --no-ri --local ")

  # For AIX, we use the triple to install a better rbconfig
  if platform.is_aix?
    platform_triple = "powerpc-ibm-aix#{platform.os_version}.0.0"
  end

  proj.setting(:platform_triple, platform_triple)
  proj.setting(:host, host)

  proj.description "The Puppet Agent package contains all of the elements needed to run puppet, including ruby, facter, hiera and mcollective."
  proj.version_from_git
  proj.write_version_file File.join(proj.prefix, 'VERSION')
  proj.license "See components"
  proj.vendor "Puppet Labs <info@puppetlabs.com>"
  proj.homepage "https://www.puppetlabs.com"
  proj.target_repo "PC1"

  if platform.is_solaris?
    proj.identifier "puppetlabs.com"
  elsif platform.is_osx?
    proj.identifier "com.puppetlabs"
  end

  # Platform specific
  # we do not use these on windows
  if platform.is_windows?
    if platform.architecture == "x64"
      arch = "64"
      proj.setting(:cflags, "-IC:/tools/pl-build-tools/include -IC:/tools/mingw#{arch}/include -IC:/tools/mingw64/x86_64-w64-mingw32/include")
      proj.setting(:ldflags, "-LC:/tools/pl-build-tools/lib -LC:/tools/mingw#{arch}/lib -LC:/tools/mingw64/x86_64-w64-mingw32/lib")
    else
      arch = "32"
      proj.setting(:cflags, "-IC:/tools/pl-build-tools/include -IC:/tools/mingw#{arch}/include -IC:/tools/mingw32/i686-w64-mingw32/include")
      proj.setting(:ldflags, "-LC:/tools/pl-build-tools/lib -LC:/tools/mingw#{arch}/lib -LC:/tools/mingw32/i686-w64-mingw32/lib")
    end
    proj.setting(:gcc_bindir, "#{platform.drive_root}/tools/mingw#{arch}/bin")
    proj.setting(:cygwin, "nodosfilewarning winsymlinks:native")
    proj.setting(:cc, "#{platform.drive_root}/tools/mingw#{arch}/bin/gcc")
    proj.setting(:cxx, "#{platform.drive_root}/tools/mingw#{arch}/bin/g++")
    proj.setting(:tools_root, "#{platform.drive_root}/tools/pl-build-tools")
  else
    proj.setting(:cflags, "-I#{proj.includedir} -I/opt/pl-build-tools/include")
    proj.setting(:ldflags, "-L#{proj.libdir} -L/opt/pl-build-tools/lib -Wl,-rpath=#{proj.libdir}")
    proj.setting(:tools_root, "/opt/pl-build-tools")
  end
  if platform.is_aix?
    proj.setting(:ldflags, "-Wl,-brtl -L#{proj.libdir} -L/opt/pl-build-tools/lib")
  end

  # First our stuff
  proj.component "puppet"
  proj.component "facter"
  proj.component "hiera"
  proj.component "marionette-collective"
  proj.component "cpp-pcp-client"
  proj.component "pxp-agent"

  # Then the dependencies
  proj.component "augeas" unless platform.is_windows?
  # Curl is only needed for compute clusters (GCE, EC2); so rpm, deb, and Windows
  proj.component "curl" if platform.is_linux? || platform.is_windows?
  proj.component "ruby"
  proj.component "ruby-stomp"
  proj.component "rubygem-deep-merge"
  proj.component "rubygem-net-ssh"
  proj.component "rubygem-hocon"
  if platform.is_windows?
    proj.component "rubygem-ffi"
    proj.component "rubygem-minitar"
    proj.component "rubygem-win32-dir"
    proj.component "rubygem-win32-eventlog"
    proj.component "rubygem-win32-process"
    proj.component "rubygem-win32-security"
    proj.component "rubygem-win32-service"
  end
  proj.component "ruby-shadow" unless platform.is_aix? || platform.is_windows?
  proj.component "ruby-augeas" unless platform.is_windows?
  proj.component "openssl"
  proj.component "puppet-ca-bundle"
  proj.component "libxml2" unless platform.is_windows?
  proj.component "libxslt" unless platform.is_windows?

  # These utilites don't really work on unix
  if platform.is_linux?
    proj.component "virt-what"
    proj.component "dmidecode"
    proj.component "shellpath"
  end

  if platform.is_solaris? || platform.name =~ /^el-4/ || platform.is_aix? || platform.is_windows?
    proj.component "runtime"
  end

  # Needed to avoid using readline on solaris and aix
  if platform.is_solaris? || platform.is_aix?
    proj.component "libedit"
  end

  # Components only applicable on OSX
  if platform.is_osx?
    proj.component "cfpropertylist"
  end

  # We only build ruby-selinux for EL 5-7
  if platform.name =~ /^el-(5|6|7)-.*/ || platform.is_fedora?
    proj.component "ruby-selinux"
  end

  proj.directory proj.install_root
  proj.directory proj.prefix
  proj.directory proj.sysconfdir
  proj.directory proj.logdir
  proj.directory proj.piddir
  proj.directory proj.link_bindir
end
