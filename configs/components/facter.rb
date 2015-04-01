component "facter" do |pkg, settings, platform|
  pkg.load_from_json('configs/components/facter.json')

  pkg.requires 'net-tools'
  pkg.build_requires 'ruby'

  pkg.replaces 'facter', '2.4.2'
  pkg.provides 'facter', '2.4.2'

  pkg.install do
    ["#{settings[:bindir]}/ruby install.rb --sitelibdir=#{settings[:ruby_vendordir]} --quick --man --mandir=#{settings[:mandir]}"]
  end

  pkg.link "#{settings[:bindir]}/facter", "#{settings[:link_bindir]}/facter"
end
