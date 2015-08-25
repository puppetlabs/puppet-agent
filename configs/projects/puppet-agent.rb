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
  proj.setting(:gem_home, File.join(proj.libdir, "ruby/gems/2.1.0"))
  proj.setting(:tmpfilesdir, "/usr/lib/tmpfiles.d")
  proj.setting(:ruby_vendordir, File.join(proj.libdir, "ruby", "vendor_ruby"))

  # For solaris, we build cross-compilers
  if platform.is_solaris?
    if platform.architecture == 'i386'
      platform_triple = "#{platform.architecture}-pc-solaris2.#{platform.os_version}"
    else
      platform_triple = "#{platform.architecture}-sun-solaris2.#{platform.os_version}"
      host = "--host #{platform_triple}"
    end
  end

  proj.setting(:platform_triple, platform_triple)
  proj.setting(:host, host)

  # If building internally, we want to use internal mirrors for speed and
  # reduced chances of failure
  if ENV["INTERNAL_PL_BUILD"].to_s.downcase == "true"
    # Here we rewrite public http urls to use our internal source host instead.
    # Something like https://www.openssl.org/source/openssl-1.0.0r.tar.gz gets
    # rewritten as
    # http://buildsources.delivery.puppetlabs.net/openssl-1.0.0r.tar.gz
    proj.register_rewrite_rule 'http', 'http://buildsources.delivery.puppetlabs.net'

    # Here we rewrite public git urls to use our internal git mirror It turns
    # urls that look like git://github.com/puppetlabs/puppet.git into
    # git://github.delivery.puppetlabs.net/puppetlabs-puppet.git
    proj.register_rewrite_rule 'git', Proc.new { |url|
      match = url.match(/github.com\/(.*)$/)
      "git://github.delivery.puppetlabs.net/#{match[1].gsub('/', '-')}" if match
    }
  end

  proj.description "The Puppet Agent package contains all of the elements needed to run puppet, including ruby, facter, hiera and mcollective."
  proj.version_from_git
  proj.write_version_file File.join(proj.prefix, 'VERSION')
  proj.license "See components"
  proj.vendor "Puppet Labs <info@puppetlabs.com>"
  proj.homepage "https://www.puppetlabs.com"
  proj.target_repo "PC1"
  proj.identifier "com.puppetlabs"

  # Platform specific
  proj.setting(:cflags, "-I#{proj.includedir} -I/opt/pl-build-tools/include")
  proj.setting(:ldflags, "-L#{proj.libdir} -L/opt/pl-build-tools/lib -Wl,-rpath=#{proj.libdir}")

  # First our stuff
  proj.component "puppet"
  proj.component "facter"
  proj.component "hiera"
  proj.component "marionette-collective"
  if proj.get_platform.is_rpm? || proj.get_platform.is_deb?
    proj.component "cpp-pcp-client"
    proj.component "pxp-agent"
  end

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

  # These utilites don't really work on unix
  if proj.get_platform.is_linux?
    proj.component "virt-what"
    proj.component "dmidecode"
  end

  # Needed to avoid using readline on solaris
  if platform.is_solaris?
    proj.component "runtime"
    proj.component "libedit"
  end

  # Components only applicable on OSX
  if proj.get_platform.is_osx?
   proj.component "cfpropertylist"
  end

  if proj.get_platform.is_solaris? || proj.get_platform.is_osx?
   proj.component "ca-cert"
  end

  # We only build ruby-selinux for EL 5-7
  if proj.get_platform.name =~ /^el-(5|6|7)-.*/
    proj.component "ruby-selinux"
  end

  proj.directory "/opt/puppetlabs"
  proj.directory proj.prefix
  proj.directory proj.sysconfdir
  proj.directory proj.logdir
  proj.directory proj.piddir
  proj.directory proj.link_bindir

end
