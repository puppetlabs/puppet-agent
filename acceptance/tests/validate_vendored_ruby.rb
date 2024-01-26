require 'puppet/acceptance/common_utils.rb'
require 'puppet/acceptance/temp_file_utils'
extend Puppet::Acceptance::CommandUtils

confine :except, :platform => 'sles-12-ppc64le'

def package_installer(agent)
  # for some reason, beaker does not have a configured package installer
  # for AIX, and for solaris-10 we install dependencies from opencsw. so we
  # need to manually set up the package installer for these platforms.
  case agent['platform']
  when /aix/
    lambda { |package| on(agent, "rm -f `basename #{package}` && curl -O #{package} && rpm -Uvh `basename #{package}`") }
  when /solaris-10/
    lambda { |package| on(agent, "opt/csw/bin/pkgutil --config=/var/tmp/vanagon-pkgutil.conf  -y -i #{package}") }
  else
    lambda { |package| agent.install_package(package) }
  end
end

def setup_build_environment(agent)
  # We set the gem path for install here to our internal shared vendor
  # path. This allows us to verify that our Ruby is able to read from
  # this path when listing / loading gems in the test below.

  # The sqlite3 gem >= 1.5.0 bundles libsqlite3, which breaks some tests
  # We add `--enable-system-libraries` to use system libsqlite3
  # Pin to 1.6.9 which was the last version to support "native gem support for 2.7"
  gem_install_sqlite3 = "env GEM_HOME=/opt/puppetlabs/puppet/lib/ruby/vendor_gems " + gem_command(agent) + " install sqlite3 -v 1.6.9 -- --enable-system-libraries"
  install_package_on_agent = package_installer(agent)
  on(agent, "#{gem_command(agent)} update --system 3.4.22")

  case agent['platform']
  when /aix/
    # use pl-build-tools' gcc on AIX machines
    gem_install_sqlite3 = "export PATH=\"/opt/pl-build-tools/bin:$PATH\" && #{gem_install_sqlite3}"
  when /solaris-11(.4|)-i386/
    # for some reason pkg install does not install developer/gcc-48 for sol 11, so need
    # to use the one provided by pl-build-tools instead.
    on(agent, "curl -O http://pl-build-tools.delivery.puppetlabs.net/solaris/11/sol-11-i386-compiler.tar.gz")
    on(agent, "gunzip -f sol-11-i386-compiler.tar.gz && tar -xf sol-11-i386-compiler.tar && rm -f sol-11-i386-compiler.tar")
    on(agent, "mv pl-build-tools/ /opt/")
    on(agent, "ln -s i386/bin /opt/pl-build-tools/bin")
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

    vanagon_pkgutil_contents = "mirror=https://artifactory.delivery.puppetlabs.net/artifactory/generic__remote_opencsw_mirror/testing"
    vanagon_pkgutil_path = "/var/tmp/vanagon-pkgutil.conf"
    on(agent, "echo \"#{vanagon_pkgutil_contents}\" > #{vanagon_pkgutil_path}")

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
    'yum' => ['gcc', 'make', 'sqlite-devel'],
    'zypper' => ['gcc', 'sqlite3-devel'],
    'opt/csw/bin/pkgutil' => ['sqlite3', 'libsqlite3_dev'],
    'rpm' => [
      'http://pl-build-tools.delivery.puppetlabs.net/aix/6.1/ppc/pl-gcc-5.2.0-11.aix6.1.ppc.rpm',
      'http://osmirror.delivery.puppetlabs.net/AIX_MIRROR/pkg-config-0.19-6.aix5.2.ppc.rpm',
      'http://osmirror.delivery.puppetlabs.net/AIX_MIRROR/info-4.6-1.aix5.1.ppc.rpm',
      'https://artifactory.delivery.puppetlabs.net/artifactory/generic__buildsources/buildsources/readline-7.0-3.aix5.1.ppc.rpm',
      'https://artifactory.delivery.puppetlabs.net/artifactory/generic__buildsources/buildsources/readline-devel-7.0-3.aix5.1.ppc.rpm',
      'https://artifactory.delivery.puppetlabs.net/artifactory/generic__buildsources/buildsources/sqlite-3.20.0-1.aix5.1.ppc.rpm',
      'https://artifactory.delivery.puppetlabs.net/artifactory/generic__buildsources/buildsources/sqlite-devel-3.20.0-1.aix5.1.ppc.rpm'
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

  step "vendored ruby successfully loads gems" do
    agents.each do |agent|
      irb = irb_command(agent)

      ['hocon', 'deep_merge', 'puppet/resource_api'].each do |gem|
        if agent['platform'] =~ /windows*/
          # Although beaker can set a PATH for puppet-agent on Windows, it isn't
          # able to set up the environment for the purpose of loading gems this
          # way; See BKR-1445 and BKR-986. As a workaround, run the environment
          # script before requiring the gem. We're using `ruby -r` instead of
          # irb here because `cmd /c` will only run one argument command before
          # returning to cygwin (additional arguments will be treated as bash)
          # and using irb introduces too many quotes.
          cmd = "env PATH=\"#{agent['privatebindir']}:${PATH}\" cmd /c \"environment.bat && ruby -r#{gem} -e 'puts true'\""
          stdout = on(agent, cmd).stdout.chomp
          assert_match(/true/, stdout, "ruby failed to require the #{gem} gem")
        else
          stdout = on(agent, "echo \"require '#{gem}'\" | #{irb}").stdout.chomp
          assert_match(/true/, stdout, "'irb' failed to require the #{gem} gem")
        end
      end
    end
  end

  step "'gem install' successfully installs a gem with native extensions" do
    agents_to_skip = select_hosts({:platform => [/windows/, /cisco/, /eos/, /cumulus/, /aix-7.3-power/]}, agents)
    agents_to_test = agents - agents_to_skip
    agents_to_test.each do |agent|
      gem_install_sqlite3 = setup_build_environment(agent)

      # Upgrade the AlmaLinux release package for newer keys until our image is updated (RE-16096)
      on(agent, 'dnf -y upgrade almalinux-release') if on(agent, facter('os.name')).stdout.strip == 'AlmaLinux'

      install_dependencies(agent)
      on(agent, gem_install_sqlite3)

      gem = gem_command(agent)
      listed_gems = on(agent, "#{gem} list").stdout.chomp
      assert_match(/sqlite3/, listed_gems, "'gem install' failed to build the sqlite3 gem")
    end
  end

  # rubygems-update >= 3.5.0 drops compatibility with Ruby 2.7, which
  # puppet-agent 7.x uses. We pin to the last version that supports Ruby 2.7,
  # rubygems-update 3.4.22.
  step "'gem update --system' keeps vendor_gems still in path" do
    agents_to_skip = select_hosts({:platform => [/windows/, /cisco/, /eos/, /cumulus/]}, agents)
    agents_to_test = agents - agents_to_skip
    agents_to_test.each do |agent|
      on(agent, "/opt/puppetlabs/puppet/bin/gem update --system 3.4.22")
      list_env = on(agent, "/opt/puppetlabs/puppet/bin/gem env").stdout.chomp
      unless list_env.include?("/opt/puppetlabs/puppet/lib/ruby/vendor_gems")
        fail_test("Failed to keep vendor_gems directory in GEM_PATH!")
      end
    end
  end
end
