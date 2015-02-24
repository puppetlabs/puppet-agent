component "rubygem-net-ssh" do |pkg, settings, platform|
  pkg.version "2.1.4"
  pkg.md5sum "797c9a7a9e25c781cbf6b77a0054bb2e"
  pkg.url "#{settings[:mirror_url]}net-ssh-#{pkg.get_version}.gem"

  pkg.build_requires "ruby"

  pkg.install do
    ["#{settings[:bindir]}/gem install --no-rdoc --no-ri net-ssh-#{pkg.get_version}.gem"]
  end
end
