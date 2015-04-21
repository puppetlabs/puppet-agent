component "facter" do |pkg, settings, platform|
  pkg.load_from_json('configs/components/facter.json')


  # net-tools is required for ifconfig; it can be removed with Facter 3
  pkg.requires 'net-tools'
  pkg.build_requires 'ruby'

  # Here we replace and provide facter 3 to ensure that even as we continue
  # to release 2.x versions of facter upgrades to puppet-agent will be clean
  if platform.is_rpm?
    # In our rpm packages, facter has an epoch set, so we need to account for that here
    pkg.replaces 'facter', '1:3.0.0'
    pkg.replaces 'pe-facter', '1:3.0.0'
    pkg.provides 'facter', '1:3.0.0'
    pkg.provides 'pe-facter', '1:3.0.0'
  else
    pkg.replaces 'facter', '3.0.0'
    pkg.replaces 'pe-facter', '3.0.0'
    pkg.provides 'facter', '3.0.0'
    pkg.provides 'pe-facter', '3.0.0'
  end

  pkg.install do
    ["#{settings[:bindir]}/ruby install.rb --sitelibdir=#{settings[:ruby_vendordir]} --quick --man --mandir=#{settings[:mandir]}"]
  end

  pkg.link "#{settings[:bindir]}/facter", "#{settings[:link_bindir]}/facter"
end
