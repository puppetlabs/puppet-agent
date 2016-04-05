component "hiera" do |pkg, settings, platform|
  pkg.load_from_json('configs/components/hiera.json')

  pkg.build_requires "ruby"
  pkg.build_requires "rubygem-deep-merge"

  pkg.replaces 'hiera', '2.0.0'
  pkg.provides 'hiera', '2.0.0'

  pkg.replaces 'pe-hiera'

  pkg.install do
    ["#{settings[:host_ruby]} install.rb \
    --ruby=#{File.join(settings[:bindir], 'ruby')} \
    --bindir=#{settings[:bindir]} \
    --configdir=#{settings[:puppet_codedir]} \
    --sitelibdir=#{settings[:ruby_vendordir]} \
    --configs \
    --quick \
    --man \
    --mandir=#{settings[:mandir]}"]
  end

  pkg.install_file ".gemspec", "#{settings[:gem_home]}/specifications/#{pkg.get_name}.gemspec"
  if platform.is_windows?
    pkg.add_source("file://resources/files/windows/hiera.bat", sum: "bbe0a513808af61ed9f4b57463851326")
    pkg.install_file "../hiera.bat", "#{settings[:link_bindir]}/hiera.bat"
  end
  pkg.configfile File.join(settings[:puppet_codedir], 'hiera.yaml')

  pkg.link "#{settings[:bindir]}/hiera", "#{settings[:link_bindir]}/hiera" unless platform.is_windows?

  if platform.is_windows?
    pkg.directory File.join(settings[:puppet_codedir], 'hieradata')
  else
    pkg.directory File.join(settings[:puppet_codedir], 'environments', 'production', 'hieradata')
  end
end
