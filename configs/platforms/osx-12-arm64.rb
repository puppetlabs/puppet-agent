platform 'osx-12-arm64' do |plat|
  plat.inherit_from_default
  packages = %w[cmake pkg-config yaml-cpp]
  plat.provision_with "su test -c '/usr/local/bin/brew install #{packages.join(' ')}'"
  # PA-5471 override default 'osx' directory
  plat.output_dir File.join('apple', '12', 'puppet8', 'arm64')
end
