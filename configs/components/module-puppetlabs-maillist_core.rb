component "module-puppetlabs-maillist_core" do |pkg, settings, platform|
  pkg.version "1.0.1"
  pkg.md5sum "575bb9d74154a48aae334bba478d19e3"

  pkg.build_requires "module-puppetlabs-mailalias_core"

  instance_eval File.read("configs/components/_base-module.rb")
end
