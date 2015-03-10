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
  proj.setting(:ruby_vendordir, File.join(proj.libdir, "ruby", "vendor_ruby"))
  proj.setting(:mirror_url, "http://buildsources.delivery.puppetlabs.net/")

  proj.description "The Puppet Agent package contains all of the elements needed to run puppet, including ruby, facter, hiera and mcollective."
  proj.version_from_git
  proj.license "ASL 2.0"
  proj.vendor "Puppet Labs <info@puppetlabs.com>"
  proj.homepage "https://www.puppetlabs.com"

  # Platform specific
  proj.setting(:cflags, "-I#{proj.includedir}")
  proj.setting(:ldflags, "-L#{proj.libdir} -Wl,-rpath=#{proj.libdir}")

  # First our stuff
  proj.component "puppet"
  proj.component "facter"
  unless ( proj.get_platform.is_eos? or proj.get_platform.is_nxos? )
    proj.component "cfacter"
  end
  proj.component "hiera"
  proj.component "mcollective"

  # Then the dependencies
  proj.component "augeas"
  proj.component "ruby"
  proj.component "ruby-stomp"
  proj.component "rubygem-deep-merge"
  proj.component "rubygem-net-ssh"
  proj.component "ruby-selinux"
  proj.component "ruby-shadow"
  proj.component "ruby-augeas"
  proj.component "openssl"
  proj.component "virt-what"

  proj.directory proj.prefix
  proj.directory proj.sysconfdir
  proj.directory proj.logdir
  proj.directory proj.piddir
  proj.directory proj.link_bindir

end
