require 'puppet/acceptance/temp_file_utils'
extend Puppet::Acceptance::CommandUtils

def install_dependencies(agent)
  # for some reason, beaker does not have a configured package installer
  # for AIX, so need to manually do it
  install_package_on_agent = agent['platform'] =~ /aix/ ?
      lambda { |package| on(agent, "rpm -Uvh #{package}") }
    : lambda { |package| agent.install_package(package) }

  dependencies = {
    'apt-get' => ['gcc', 'make', 'libsqlite3-dev'],
    'yum' => ['gcc', 'sqlite-devel'],
    'zypper' => ['gcc', 'sqlite3-devel'],
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
    on(agent, "which #{_provider}", :accept_all_exit_codes => true).exit_code.zero? 
  end
  assert(provider, "The agent does not have one of `apt-get`, `yum`, `zypper`, or `rpm` as its package provider")

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
    agents_to_skip = select_hosts({:platform => [/windows/, /solaris/, /cisco/, /eos/, /cumulus/, /sles.+ppc/]}, agents)
    agents_to_test = agents - agents_to_skip
    agents_to_test.each do |agent|
      if agent['platform'] !~ /osx/
        install_dependencies(agent)
      end

      gem = gem_command(agent)
      # use pl-build-tools' gcc on AIX machines
      gem = "export PATH=\"/opt/pl-build-tools/bin:$PATH\" && #{gem}" if agent['platform'] =~ /aix/

      on(agent, "#{gem} install sqlite3")
      listed_gems = on(agent, "#{gem} list").stdout.chomp
      assert_match(/sqlite3/, listed_gems, "'gem install' failed to build the sqlite3 gem")
    end
  end
end

