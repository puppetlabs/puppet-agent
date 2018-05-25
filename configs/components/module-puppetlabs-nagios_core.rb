component "module-puppetlabs-nagios_core" do |pkg, settings, platform|
  pkg.load_from_json("configs/components/module-puppetlabs-nagios_core.json")

  instance_eval File.read("configs/components/_base-module.rb")
end
