component "module-puppetlabs-mailalias_core" do |pkg, settings, platform|
  pkg.load_from_json("configs/components/module-puppetlabs-mailalias_core.json")

  instance_eval File.read("configs/components/_base-module.rb")
end
