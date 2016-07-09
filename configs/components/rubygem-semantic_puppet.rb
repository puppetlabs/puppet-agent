component "rubygem-semantic_puppet" do |pkg, settings, platform|
  pkg.url "git@github.com:puppetlabs/semantic_puppet.git"
  pkg.ref "v0.1.2"

  pkg.install do
    ["cp -pr lib/* #{settings[:ruby_vendordir]}"]
  end
end
