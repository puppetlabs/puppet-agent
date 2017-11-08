require 'puppet/acceptance/temp_file_utils'
extend Puppet::Acceptance::CommandUtils

def package_installer(agent)
  # for some reason, beaker does not have a configured package installer
  # for AIX, and for solaris-10 we install dependencies from opencsw. so we
  # need to manually set up the package installer for these platforms.
  case agent['platform']
  when /aix/
    lambda { |package| on(agent, "rpm -Uvh #{package}") }
  when /solaris-10/
    lambda { |package| on(agent, "opt/csw/bin/pkgutil -y -i #{package}") }
  else
    lambda { |package| agent.install_package(package) }
  end
end

def setup_build_environment(agent)
  gem_install_sqlite3 = gem_command(agent) + " install sqlite3"
  install_package_on_agent = package_installer(agent)

  case agent['platform'] 
  when /aix/
    # use pl-build-tools' gcc on AIX machines
    gem_install_sqlite3 = "export PATH=\"/opt/pl-build-tools/bin:$PATH\" && #{gem_install_sqlite3}"
  when /el-5/
    # PA-1638
    gem_install_sqlite3 += " -v 1.3.11" 
  when /solaris-11-i386/
    # for some reason pkg install does not install developer/gcc-48 for sol 11, so need
    # to use the one provided by pl-build-tools instead.
    on(agent, "curl -O http://pl-build-tools.delivery.puppetlabs.net/solaris/11/sol-11-i386-compiler.tar.gz")
    on(agent, "gunzip sol-11-i386-compiler.tar.gz && tar -xf sol-11-i386-compiler.tar")
    on(agent, "mv pl-build-tools/ /opt/")
    gem_install_sqlite3 = "export PATH=\"/opt/pl-build-tools/i386/bin:/usr/sfw/bin:$PATH\" && #{gem_install_sqlite3}"
  when /solaris-11-sparc/
    install_package_on_agent.call("developer/gcc-48")
    gem_install_sqlite3 = "export PATH=\"/usr/gcc/4.8/bin:$PATH\" && #{gem_install_sqlite3}"
  when /solaris-10/
    # this code was obtained from https://github.com/puppetlabs/puppet-agent/blob/master/configs/platforms/solaris-10-i386.rb
    # it's main purpose is to set up a base build environment that lets you compile stuff
    # on the vm (e.g. by installing the system headers). otherwise, you would not be able to
    # compile even a hello-world.c program.
    vanagon_noask_contents = "mail=\n"\
      "instance=overwrite\n"\
      "partial=nocheck\n"\
      "runlevel=nocheck\n"\
      "idepend=nocheck\n"\
      "rdepend=nocheck\n"\
      "space=quit\n"\
      "setuid=nocheck\n"\
      "conflict=nocheck\n"\
      "action=nocheck\n"\
      "basedir=default"
    vanagon_noask_path = "/var/tmp/vanagon-noask"
    on(agent, "echo \"#{vanagon_noask_contents}\" > #{vanagon_noask_path}")

    on(agent, "pkgadd -n -a #{vanagon_noask_path} -G -d http://get.opencsw.org/now all")
    ["rsync", "gmake", "pkgconfig", "ggrep", "gcc4core"].each { |pkg| install_package_on_agent.call(pkg) }
    install_package_on_agent.call("coreutils") if agent['platform'] =~ /sparc/
    on(agent, "ln -sf /opt/csw/bin/rsync /usr/bin/rsync")
    ["glibc-devel", "ruby", "readline"].each do |pkg|
      on(agent, "/opt/csw/bin/pkgutil -l #{pkg} | xargs -I{} pkgrm -n -a #{vanagon_noask_path} {}")
    end

    bin_dirs = ["/opt/csw/bin"]
    if agent['platform'] =~ /sparc/
      bin_dirs.concat(["/usr/sfw/bin", "/usr/ccs/bin"])
    else
      # for some reason, sparc has everything else that it needs (system headers, gcc, etc.),
      # but i386 does not. the code below ensures that all these dev tools are installed for i386.
      # note that we probably don't need everything here, but it is too time consuming to check
      # which one of these are necessary
      base_url = "http://pl-build-tools.delivery.puppetlabs.net/solaris/10/depends"
      ['arc', 'gnu-idn', 'gpch', 'gtar', 'hea', 'libm', 'wgetu', 'xcu4'].each do |pkg|
        tmpdir = on(agent, "mktemp -p /var/tmp -d").stdout.chomp
        pkg_gz = "SUNW#{pkg}.pkg.gz"
        in_temp_dir = lambda do |cmd|
          "pushd #{tmpdir} && #{cmd} && popd"
        end
  
        on(agent, in_temp_dir.call("curl -O #{base_url}/#{pkg_gz}"))
        on(agent, in_temp_dir.call("gunzip -c #{pkg_gz} | pkgadd -d /dev/stdin -a #{vanagon_noask_path} all"))
      end
    end

    gem_install_sqlite3 = "export PATH=\"#{bin_dirs.join(":")}:$PATH\" && #{gem_install_sqlite3}"
  end

  gem_install_sqlite3
end

def install_dependencies(agent)
  return if agent['platform'] =~ /osx|solaris-11|sparc/

  install_package_on_agent = package_installer(agent) 
  dependencies = {
    'apt-get' => ['gcc', 'make', 'libsqlite3-dev'],
    'yum' => ['gcc', 'sqlite-devel'],
    'zypper' => ['gcc', 'sqlite3-devel'],
    'opt/csw/bin/pkgutil' => ['sqlite3', 'libsqlite3_dev'],
    'rpm' => [
      'http://pl-build-tools.delivery.puppetlabs.net/aix/5.3/ppc/pl-gcc-5.2.0-1.aix5.3.ppc.rpm',
      'http://osmirror.delivery.puppetlabs.net/AIX_MIRROR/pkg-config-0.19-6.aix5.2.ppc.rpm',
      'http://osmirror.delivery.puppetlabs.net/AIX_MIRROR/info-4.6-1.aix5.1.ppc.rpm',
      'http://www.oss4aix.org/download/RPMS/readline/readline-7.0-3.aix5.1.ppc.rpm',
      'http://www.oss4aix.org/download/RPMS/readline/readline-devel-7.0-3.aix5.1.ppc.rpm',
      'http://www.oss4aix.org/download/RPMS/sqlite/sqlite-3.20.0-1.aix5.1.ppc.rpm',
      'http://www.oss4aix.org/download/RPMS/sqlite/sqlite-devel-3.20.0-1.aix5.1.ppc.rpm'
    ]
  }

  provider = dependencies.keys.find do |_provider|
    result = on(agent, "which #{_provider}", :accept_all_exit_codes => true)
    # the `which` command on Solaris returns a 0 exit code even when the file
    # does not exist
    agent['platform'] =~ /solaris/ ?
       result.stdout.chomp !~ /no #{_provider}/
     : result.exit_code.zero? 
  end
  providers = dependencies.keys.join(', ')
  assert(provider, "The agent does not have one of #{providers} as its package provider")

  dependencies[provider].each do |dependency|
    install_package_on_agent.call(dependency)
  end
end

test_name 'PA-1319: Validate that the vendored ruby can load gems and is configured correctly' do

  step "'gem list' displays a decent list of gems" do
    minimum_number_of_gems = 3
    # \d+\.\d+\.\d+ describes the gem version
    gem_re = /[\w-]+ \(\d+\.\d+\.\d+(?:, \d+\.\d+\.\d+)*\)/

    agents.each do |agent|
      gem = gem_command(agent) 
      listed_gems = on(agent, "#{gem} list").stdout.chomp.scan(gem_re)
      assert(listed_gems.size >= minimum_number_of_gems, "'gem list' fails to list the available gems (i.e., the rubygems environment is not sane)")
    end
  end

  step "'irb' successfully loads gems" do
    agents.each do |agent|
      irb = irb_command(agent)
      ['hocon', 'deep_merge'].each do |gem|
        stdout = on(agent, "echo \"require '#{gem}'\" | #{irb}").stdout.chomp
        assert_match(/true/, stdout, "'irb' failed to require the #{gem} gem")
      end
    end
  end

  step "'gem install' successfully installs a gem with native extensions" do
    # SLES POWER machines will be skipped until OPS-15487 is resolved
    agents_to_skip = select_hosts({:platform => [/windows/, /cisco/, /eos/, /cumulus/]}, agents)
    agents_to_test = agents - agents_to_skip
    agents_to_test.each do |agent|
      gem_install_sqlite3 = setup_build_environment(agent)
      install_dependencies(agent)
      on(agent, gem_install_sqlite3)

      gem = gem_command(agent)
      listed_gems = on(agent, "#{gem} list").stdout.chomp
      assert_match(/sqlite3/, listed_gems, "'gem install' failed to build the sqlite3 gem")
    end
  end
end

