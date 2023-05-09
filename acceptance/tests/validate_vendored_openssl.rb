test_name 'Validate openssl version and fips' do
  tag 'audit:high'

  def openssl_command(host)
    puts "privatebindir=#{host['privatebindir']}"
    "env PATH=\"#{host['privatebindir']}:${PATH}\" openssl"
  end

  agents.each do |agent|
    openssl = openssl_command(agent)

    step "check openssl version" do
      on(agent, "#{openssl} version -v") do |result|
        assert_match(/^OpenSSL 3\./, result.stdout)
      end
    end

    if agent['template'] =~ /^redhat-fips/
      step "check fips_enabled fact" do
        on(agent, facter("fips_enabled")) do |result|
          assert_match(/^true/, result.stdout)
        end
      end

      step "check openssl providers" do
        on(agent, "#{openssl} list -providers") do |result|
          assert_match(Regexp.new(<<~END, Regexp::MULTILINE), result.stdout)
          \s*fips
          \s*name: OpenSSL FIPS Provider
          \s*version: 3.0.0
          \s*status: active
          END
        end
      end

      step "check fipsmodule.cnf" do
        on(agent, "#{openssl} fipsinstall -module /opt/puppetlabs/puppet/lib/ossl-modules/fips.so -provider_name fips -in /opt/puppetlabs/puppet/ssl/fipsmodule.cnf -verify") do |result|
          assert_match(/VERIFY PASSED/, result.stderr)
        end
      end
    end
  end
end
