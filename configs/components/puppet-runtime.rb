component 'puppet-runtime' do |pkg, settings, platform|
  unless settings[:puppet_runtime_version] && settings[:puppet_runtime_location] && settings[:puppet_runtime_basename]
    raise "Expected to find :puppet_runtime_version, :puppet_runtime_location, and :puppet_runtime_basename settings; Please set these in your project file before including puppet-runtime as a component."
  end

  pkg.version settings[:puppet_runtime_version]

  tarball_name = "#{settings[:puppet_runtime_basename]}.tar.gz"
  pkg.url File.join(settings[:puppet_runtime_location], tarball_name)
  pkg.sha1sum File.join(settings[:puppet_runtime_location], "#{tarball_name}.sha1")

  # The contents of the runtime replace the following:
  pkg.replaces 'pe-augeas'
  pkg.replaces 'pe-openssl'
  pkg.replaces 'pe-ruby'
  pkg.replaces 'pe-ruby-mysql'
  pkg.replaces 'pe-rubygems'
  pkg.replaces 'pe-libyaml'
  pkg.replaces 'pe-libldap'
  pkg.replaces 'pe-ruby-ldap'
  pkg.replaces 'pe-ruby-augeas'
  pkg.replaces 'pe-ruby-selinux'
  pkg.replaces 'pe-ruby-shadow'
  pkg.replaces 'pe-ruby-stomp'
  pkg.replaces 'pe-rubygem-deep-merge'
  pkg.replaces 'pe-rubygem-net-ssh'

  # These platforms are built with the default OS distro toolchain, and
  # thus have additional package deps
  if platform.name =~ /sles-15/
    pkg.requires 'libboost_atomic1_66_0'
    pkg.requires 'libboost_chrono1_66_0'
    pkg.requires 'libboost_date_time1_66_0'
    pkg.requires 'libboost_filesystem1_66_0'
    pkg.requires 'libboost_locale1_66_0'
    pkg.requires 'libboost_log1_66_0'
    pkg.requires 'libboost_program_options1_66_0'
    pkg.requires 'libboost_random1_66_0'
    pkg.requires 'libboost_regex1_66_0'
    pkg.requires 'libyaml-cpp0_6'
  end

  pkg.install_only true

  if platform.is_cross_compiled_linux? || platform.is_solaris? || platform.is_aix?
    pkg.build_requires 'runtime'
  end

  # Even though puppet's ruby comes from puppet-runtime, we still need a ruby
  # to build with on these platforms:
  if platform.architecture == "sparc"
    if platform.os_version == "11"
      pkg.build_requires 'pl-ruby'
    end
  elsif platform.is_cross_compiled_linux?
    pkg.build_requires 'pl-ruby'
  end

  if platform.is_windows?
    # Elevate.exe is simply used when one of the run_facter.bat or
    # run_puppet.bat files are called. These set up the required environment
    # for the program, and elevate.exe gives the program the elevated
    # privileges it needs to run
    pkg.add_source "file://resources/files/windows/elevate.exe.config", sum: "a5aecf3f7335fa1250a0f691d754d561"
    pkg.add_source "#{settings[:buildsources_url]}/windows/elevate/elevate.exe", sum: "bd81807a5c13da32dd2a7157f66fa55d"
    pkg.install_file 'elevate.exe.config', "#{settings[:windows_tools]}/elevate.exe.config"
    pkg.install_file 'elevate.exe', "#{settings[:windows_tools]}/elevate.exe"

    # We need to make sure we're setting permissions correctly for the executables
    # in the ruby bindir since preserving permissions in archives in windows is
    # ... weird, and we need to be able to use cygwin environment variable use
    # so cmd.exe was not working as expected.
    install_command = [
      "gunzip -c #{tarball_name} | tar -k -C /cygdrive/c/ -xf -",
      "chmod 755 #{settings[:ruby_bindir].sub(/C:/, '/cygdrive/c')}/*"
    ]
  elsif platform.is_macos?
    # We can't untar into '/' because of SIP on macOS; Just copy the contents
    # of these directories instead:
    install_command = [
      "tar -xzf #{tarball_name}",
      "for d in opt var private; do rsync -ka \"$${d}/\" \"/$${d}/\"; done"
    ]
  else
    install_command = ["gunzip -c #{tarball_name} | #{platform.tar} -k -C / -xf -"]
  end

  pkg.install do
    install_command
  end
end
