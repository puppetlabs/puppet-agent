project "puppet-agent" do |proj|
  # Project level settings our components will care about
  proj.setting(:prefix, "/opt/puppetlabs/puppet")
  proj.setting(:sysconfdir, "/etc/puppetlabs")
  proj.setting(:puppet_configdir, File.join(proj.sysconfdir, 'puppet'))
  proj.setting(:puppet_codedir, "/etc/puppetlabs/code")
  proj.setting(:logdir, "/var/log/puppetlabs")
  proj.setting(:piddir, "/var/run/puppetlabs")
  proj.setting(:bindir, File.join(proj.prefix, "bin"))
  proj.setting(:link_bindir, "/opt/puppetlabs/bin")
  proj.setting(:libdir, File.join(proj.prefix, "lib"))
  proj.setting(:includedir, File.join(proj.prefix, "include"))
  proj.setting(:datadir, File.join(proj.prefix, "share"))
  proj.setting(:mandir, File.join(proj.datadir, "man"))
  proj.setting(:tmpfilesdir, "/usr/lib/tmpfiles.d")
  proj.setting(:ruby_vendordir, File.join(proj.libdir, "ruby", "vendor_ruby"))

  proj.description "The Puppet Agent package contains all of the elements needed to run puppet, including ruby, facter, hiera and mcollective."
  proj.version_from_git
  proj.write_version_file File.join(proj.prefix, 'VERSION')
  proj.license "See components"
  proj.vendor "Puppet Labs <info@puppetlabs.com>"
  proj.homepage "https://www.puppetlabs.com"
  proj.target_repo "PC1"
  proj.identifier "com.puppetlabs"

  # Platform specific
  proj.setting(:cflags, "-I#{proj.includedir}")
  proj.setting(:ldflags, "-L#{proj.libdir} -Wl,-rpath=#{proj.libdir}")

  # First our stuff
  proj.component "puppet"
  proj.component "facter"
  proj.component "hiera"
  proj.component "marionette-collective"

  # Then the dependencies
  proj.component "augeas"
  # Curl is only needed for compute clusters (GCE, EC2); so rpm, deb, and Windows
  proj.component "curl" if proj.get_platform.is_rpm? || proj.get_platform.is_deb?
  proj.component "ruby"
  proj.component "ruby-stomp"
  proj.component "rubygem-deep-merge"
  proj.component "rubygem-net-ssh"
  proj.component "rubygem-hocon"
  proj.component "ruby-shadow"
  proj.component "ruby-augeas"
  proj.component "openssl"
  proj.component "virt-what"

  # Components only applicable on OSX
  if proj.get_platform.is_osx?
   proj.component "cfpropertylist"
   proj.component "ca-cert"
  end

  # We only build ruby-selinux for EL 5-7
  if proj.get_platform.name =~ /^el-(5|6|7)-.*/
    proj.component "ruby-selinux"
  end

  proj.directory proj.prefix
  proj.directory proj.sysconfdir
  proj.directory proj.logdir
  proj.directory proj.piddir
  proj.directory proj.link_bindir

end
