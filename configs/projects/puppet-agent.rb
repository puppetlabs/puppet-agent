project "puppet-agent" do |proj|
  platform = proj.get_platform

  # Project level settings our components will care about
  # Windows has its own separate layout
  if platform.is_windows?
    # Our install prefix can't have spaces in it, so we take advantage of short cuts.
    # However, in order to take advantage of these shortcuts, we need to explicitly
    # create the directories before using any shortcuts
    proj.directory "C:/Program Files/Puppet Labs"
    proj.setting(:install_root, "C:/Progra~1/Puppet~1")
    proj.setting(:prefix, File.join(proj.install_root, "Puppet"))
    proj.setting(:sysconfdir, "C:/ProgramData/PuppetLabs")
    proj.setting(:puppet_configdir, File.join(proj.sysconfdir, 'puppet', 'etc'))
    proj.setting(:link_bindir, File.join(proj.prefix, "bin"))
    proj.setting(:logdir, File.join(proj.sysconfdir, "puppet", "var", "log"))
    proj.setting(:piddir, File.join(proj.sysconfdir, "puppet", "var", "run"))
    proj.setting(:tmpfilesdir, "C:/Windows/Temp")
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
    proj.setting(:link_bindir, "/opt/puppetlabs/bin")
    proj.setting(:logdir, "/var/log/puppetlabs")
    proj.setting(:piddir, "/var/run/puppetlabs")
    proj.setting(:tmpfilesdir, "/usr/lib/tmpfiles.d")
  end

  proj.setting(:puppet_codedir, File.join(proj.sysconfdir, 'code'))
  proj.setting(:bindir, File.join(proj.prefix, "bin"))
  proj.setting(:libdir, File.join(proj.prefix, "lib"))
  proj.setting(:includedir, File.join(proj.prefix, "include"))
  proj.setting(:datadir, File.join(proj.prefix, "share"))
  proj.setting(:mandir, File.join(proj.datadir, "man"))
  proj.setting(:gem_home, File.join(proj.libdir, "ruby", "gems", "2.1.0"))
  proj.setting(:ruby_vendordir, File.join(proj.libdir, "ruby", "vendor_ruby"))

  if platform.is_windows?
    proj.setting(:host_ruby, File.join(proj.bindir, "ruby.exe"))
    proj.setting(:host_gem, File.join(proj.bindir, "gem.bat"))
  else
    proj.setting(:host_ruby, File.join(proj.bindir, "ruby"))
    proj.setting(:host_gem, File.join(proj.bindir, "gem"))
  end

  # HuaweiOS is a cross-compiled platform
  if platform.is_huaweios?
    platform_triple = "powerpc-linux-gnu"
    host = "--host #{platform_triple}"

    # Use a standalone ruby for cross-compilation
    proj.setting(:host_ruby, "/opt/pl-build-tools/bin/ruby")
    proj.setting(:host_gem, "/opt/pl-build-tools/bin/gem")

    # This will be removed once vanagon fixes are in to specify the
    # debian target arch:
    proj.noarch
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
    platform_triple = platform.platform_triple
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

  # For some platforms the default doc location for the BOM does not exist or is incorrect - move it to specified directory
  if platform.name =~ /cisco-wrlinux/
    proj.bill_of_materials File.join(proj.datadir, "doc")
  end

  # Platform specific
  if platform.is_windows?
    arch = platform.architecture == "x64" ? "64" : "32"
    proj.setting(:gcc_root, "C:/tools/mingw#{arch}")
    proj.setting(:gcc_bindir, "#{proj.gcc_root}/bin")
    proj.setting(:tools_root, "C:/tools/pl-build-tools")
    proj.setting(:cflags, "-I#{proj.tools_root}/include -I#{proj.gcc_root}/include -I#{proj.includedir}")
    proj.setting(:ldflags, "-L#{proj.tools_root}/lib -L#{proj.gcc_root}/lib -L#{proj.libdir}")
    proj.setting(:cygwin, "nodosfilewarning winsymlinks:native")
  else
    proj.setting(:cflags, "-I#{proj.includedir} -I/opt/pl-build-tools/include")
    proj.setting(:ldflags, "-L#{proj.libdir} -L/opt/pl-build-tools/lib -Wl,-rpath=#{proj.libdir}")
  end
  if platform.is_aix?
    proj.setting(:ldflags, "-Wl,-brtl -L#{proj.libdir} -L/opt/pl-build-tools/lib")
  end

  # First our stuff
  proj.component "puppet"
  proj.component "facter"
  proj.component "hiera"
  proj.component "leatherman"
  proj.component "marionette-collective"
  proj.component "cpp-pcp-client"
  proj.component "pxp-agent"

  # Then the dependencies
  proj.component "augeas" unless platform.is_windows?
  # Curl is only needed for compute clusters (GCE, EC2); so rpm, deb, and Windows
  proj.component "curl" if (platform.is_linux? && !platform.is_huaweios?) || platform.is_windows?
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

  if platform.is_solaris? || platform.name =~ /^huaweios|^el-4/ || platform.is_aix? || platform.is_windows?
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

  # We're creating this directory on windows in the above windows block
  proj.directory proj.install_root unless platform.is_windows?
  proj.directory proj.prefix
  proj.directory proj.sysconfdir
  proj.directory proj.logdir
  proj.directory proj.piddir

  # We don't have the ability to create links on windows yet
  proj.directory proj.link_bindir unless platform.is_windows?
end
