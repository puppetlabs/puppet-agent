require 'puppet/acceptance/common_utils'

test_name "Install Packages"

step "Install puppet-agent..." do
  opts = {
    :puppet_agent_version => ENV['SUITE_VERSION'] || ENV['SHA'],
    :default_action => 'gem_install'
  }
  agents.each do |agent|
    next if agent == master
    
    # Move the openssl libs package to a newer version on redhat platforms
    if agent[:platform].match(/(?:el-7|redhat-7)/)
      step "Upgrade openssl package..." do
      end
      on(agent, "yum -y install openssl-1.0.1e-51.el7_2.4.x86_64")
    else
      step "Skipping upgrade of openssl package... (not redhat platform)" do
      end
    end

    if ENV['TESTING_RELEASED_PACKAGES']
      # installs both release repo and agent package
      install_puppet_agent_on(agent, opts)
    else
      opts.merge!({
        :dev_builds_url => ENV['AGENT_DOWNLOAD_URL'],
        :puppet_agent_sha => ENV['SHA']
      })
      # installs both development repo and agent package
      install_puppet_agent_dev_repo_on(agent, opts)
    end
  end
end

step "Install puppetserver..." do
  if ENV['SERVER_VERSION'].nil? || ENV['SERVER_VERSION'] == 'latest'
    server_version = 'latest'
    server_download_url = "http://nightlies.puppet.com"
  else
    server_version = ENV['SERVER_VERSION']
    server_download_url = "http://builds.delivery.puppetlabs.net"
  end

  # Move the openssl libs package to a newer version on redhat platforms
  if master[:platform].match(/(?:el-7|redhat-7)/)
    step "Upgrade openssl package..." do
    end
    on(master, "yum -y install openssl-1.0.1e-51.el7_2.4.x86_64")
  else
    step "Skipping upgrade of openssl package... (not redhat platform)" do
    end
  end

  if master[:hypervisor] == 'ec2'
    if master[:platform].match(/(?:el|centos|oracle|redhat|scientific)/)
      # An EC2 master instance does not have access to puppetlabs.net for getting
      # dev repos. We will install the nightly repo to satisfy the puppetserver
      # requirement and then override it with the targeted SHA package later
      # So, install the puppet-agent package directly
      if server_version == 'latest'
        logger.info "EC2 master found: Installing nightly build of puppet-agent repo to satisfy puppetserver dependency."
        install_repos_on(master, 'puppet-agent', 'nightly', 'repo-configs')
        install_repos_on(master, 'puppetserver', 'nightly', 'repo-configs')
      else
        variant, version = master['platform'].to_array
        if server_version.to_i < 5
          logger.info "EC2 master found: Installing nightly build of puppet-agent repo to satisfy puppetserver dependency."
          on(master, "rpm -Uvh https://yum.puppetlabs.com/puppetlabs-release-pc1-el-#{version}.noarch.rpm")
        else
          logger.info "EC2 master found: Installing nightly build of puppet-agent repo to satisfy puppetserver dependency."
          on(master, "rpm -Uvh https://yum.puppetlabs.com/puppet5-release-el-#{version}.noarch.rpm")
        end
      end

      master.install_package('puppetserver')

      logger.info "EC2 master found: Installing #{ENV['SHA']} build of puppet-agent."
      # Override nightly puppet-agent with targeted SHA.
      # Currently, only an `el` master is supported for this operation.
      opts = {
        :puppet_collection => 'PC1',
        :puppet_agent_sha => ENV['SHA'],
        :puppet_agent_version => ENV['SUITE_VERSION'] || ENV['SHA'] ,
        :dev_builds_url => "http://builds.delivery.puppetlabs.net"
      }

      copy_dir_local = File.join('tmp', 'repo_configs', master['platform'])
      release_path_end, release_file = master.puppet_agent_dev_package_info( opts[:puppet_collection], opts[:puppet_agent_version], opts)
      release_path = "#{opts[:dev_builds_url]}/puppet-agent/#{opts[:puppet_agent_sha]}/repos/"
      release_path << release_path_end
      fetch_http_file(release_path, release_file, copy_dir_local)
      scp_to master, File.join(copy_dir_local, release_file), master.external_copy_base
      on master, "rpm -Uvh #{File.join(master.external_copy_base, release_file)} --oldpackage --force"
    else
      fail_test("EC2 master found, but it was not an `el` host: The specified `puppet-agent` build (#{ENV['SHA']}) cannot be installed.")
    end
  else
    install_puppetlabs_dev_repo(master, 'puppetserver', server_version, nil, :dev_builds_url => server_download_url)
    install_puppetlabs_dev_repo(master, 'puppet-agent', ENV['SHA'])
    master.install_package('puppetserver')
  end

end

# make sure install is sane, beaker has already added puppet and ruby
# to PATH in ~/.ssh/environment
agents.each do |agent|
  on agent, puppet('--version')
  ruby = Puppet::Acceptance::CommandUtils.ruby_command(agent)
  on agent, "#{ruby} --version"
end

# Get a rough estimate of clock skew among hosts
times = []
hosts.each do |host|
  ruby = Puppet::Acceptance::CommandUtils.ruby_command(host)
  on(host, "#{ruby} -e 'puts Time.now.strftime(\"%Y-%m-%d %T.%L %z\")'") do |result|
    times << result.stdout.chomp
  end
end
times.map! do |time|
  (Time.strptime(time, "%Y-%m-%d %T.%L %z").to_f * 1000.0).to_i
end
diff = times.max - times.min
if diff < 60000
  logger.info "Host times vary #{diff} ms"
else
  logger.warn "Host times vary #{diff} ms, tests may fail"
end
