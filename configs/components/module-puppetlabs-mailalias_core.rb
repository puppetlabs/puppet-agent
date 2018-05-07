component "module-puppetlabs-mailalias_core" do |pkg, settings, platform|
  pkg.version "1.0.2"
  pkg.md5sum "8221ef8868bbea49ba379fd9b398b46a"

  instance_eval File.read("configs/components/_base-module.rb")
end
