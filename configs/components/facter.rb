component "facter" do |pkg, settings, platform|
  pkg.load_from_json('configs/components/facter.json')

  pkg.build_requires 'ruby'

  pkg.replaces 'facter'

  pkg.install do
    ["#{settings[:bindir]}/ruby install.rb --sitelibdir=#{settings[:ruby_vendordir]} --quick --man --mandir=#{settings[:mandir]}"]
  end
end
