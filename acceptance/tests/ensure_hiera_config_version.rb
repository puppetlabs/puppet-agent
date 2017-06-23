test_name 'C100304: Ensure hiera.yaml file contains version 5 format on new install' do
  tag 'risk:high'

  def environment_hiera_conf(agent)
    environment_path = on(agent, puppet("config print environmentpath")).stdout.chomp
    File.join(environment_path, 'production', 'hiera.yaml')
  end

  def puppet_hiera_conf(agent)
    on(agent, puppet("config print hiera_config")).stdout.chomp
  end

  agents.each do |agent|
    [puppet_hiera_conf(agent), environment_hiera_conf(agent)].each do |file|
      step "hiera.yaml contains 'version 5'" do
        on(agent, "cat #{file}", ) do |cat_results|
          assert_match(/^\s*version: 5/, cat_results.stdout, "Expected to find specific hiera version")
          assert_empty(cat_results.stderr, "Expected to not produce an error")
        end
      end
    end
  end
end
