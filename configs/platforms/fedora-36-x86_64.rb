platform 'fedora-36-x86_64' do |plat|
  plat.inherit_from_default

  packages = %w[binutils]
  plat.provision_with("/usr/bin/dnf install -y --best --allowerasing #{packages.join(' ')}")
end
