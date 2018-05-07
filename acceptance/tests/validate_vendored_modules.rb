VENDOR_MODULES = "/opt/puppetlabs/puppet/vendor_modules/"

test_name "PA-1998: Validate that vendored modules are installed" do
  step "'module list' lists the vendored modules and reports no missing dependencies" do
    agents.each do |agent|
      on(agent, puppet("module --modulepath=#{VENDOR_MODULES} list")) do |result|
        refute_empty(result.stdout.strip, "Expected to find vendor modules in #{VENDOR_MODULES}, but the directory did not exist")
        refute_match(/no modules installed/i, result.stdout, "Expected to find vendor modules in #{VENDOR_MODULES}, but the directory was empty")
        refute_match(/Missing dependency/i, result.stderr, "Some vendored module dependencies are missing in #{VENDOR_MODULES}")
      end
    end
  end

  step "`describe --list` lists vendored module types" do
    agents.each do |agent|
      on(agent, puppet("describe --modulepath=#{VENDOR_MODULES} --list")) do |result|
        assert_match(/mailalias/, result.stdout, "Vendored module type `mailalias` didn't appear in the list of known types")
      end
    end
  end
end
