component "hiera" do |pkg, settings, platform|
  pkg.load_from_json('configs/components/hiera.json')

  pkg.build_requires "ruby"
  pkg.build_requires "rubygem-deep-merge"

  pkg.replaces 'hiera', '2.0.0'
  pkg.provides 'hiera', '2.0.0'

  pkg.install do
    "#{settings[:bindir]}/ruby install.rb --configdir=#{settings[:puppet_codedir]} --sitelibdir=#{settings[:ruby_vendordir]} --configs --quick --man --mandir=#{settings[:mandir]}"
  end

  pkg.configfile File.join(settings[:puppet_codedir], 'hiera.yaml')

  pkg.link "#{settings[:bindir]}/hiera", "#{settings[:link_bindir]}/hiera"

  pkg.directory File.join(settings[:puppet_codedir], 'hieradata')
end
