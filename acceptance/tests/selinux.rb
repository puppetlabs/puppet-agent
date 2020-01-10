test_name 'PA-3067: Manage selinux' do

  tag 'audit:low',
      'audit:acceptance'

  confine :to, :platform => /el-|fedora-|debian-|ubuntu-/
  confine :except, :platform => /ubuntu-.*-ppc64el|ubuntu-14|fedora-28|el-6/

  require 'puppet/acceptance/common_utils'

  agents.each do |agent|
    step "test require 'selinux'"
      on agent, "#{ruby_command(agent)} -e 'require \"selinux\"'"
  end
end