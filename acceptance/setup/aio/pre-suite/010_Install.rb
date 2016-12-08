require 'puppet/acceptance/common_utils'

test_name "Install Packages"

step "Install puppet-agent..." do
  opts = {
    :puppet_agent_version => ENV['SHA'],
    :default_action => 'gem_install'
  }
  agents.each do |agent|
    next if agent == master
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
  if ENV['TESTING_RELEASED_PACKAGES']
    # unlike the install_puppet_agent_* beaker methods,
    # install_puppetlabs_release_repo_on does not use pc1 by default. Have to
    # supply pc1 arg to install from pc1 rather than latest in pre-puppet
    # collection repos which was version 1.2.0.
    install_puppetlabs_release_repo_on(master, 'pc1')
  else
    # the dev repos have only a single package, so we need one for both server
    # and agent to satisfy server's dep on agent
    install_puppetlabs_dev_repo(master, 'puppetserver', ENV['SERVER_VERSION'], nil, :dev_builds_url => ENV['SERVER_DOWNLOAD_URL'])
    install_puppetlabs_dev_repo(master, 'puppet-agent', ENV['SHA'], nil, :dev_builds_url => ENV['AGENT_DOWNLOAD_URL'])
  end
  master.install_package('puppetserver')
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