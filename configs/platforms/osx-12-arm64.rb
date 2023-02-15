platform 'osx-12-arm64' do |plat|
  plat.inherit_from_default
  packages = %w[cmake pkg-config yaml-cpp]
  plat.provision_with "su test -c '/usr/local/bin/brew install #{packages.join(' ')}'"
end
