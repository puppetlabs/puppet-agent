component "hiera" do |pkg, settings, platform|
  pkg.load_from_json('configs/components/hiera.json')

  pkg.build_requires "ruby"
  pkg.build_requires "rubygem-deep-merge"

  pkg.replaces 'hiera', '2.0.0'
  pkg.provides 'hiera', '2.0.0'

  pkg.replaces 'pe-hiera'

  configdir = settings[:puppet_configdir]
  flags = " --bindir=#{settings[:bindir]} \
            --sitelibdir=#{settings[:ruby_vendordir]} \
            --ruby=#{File.join(settings[:bindir], 'ruby')} "
  if platform.is_windows?
    configdir = File.join(settings[:sysconfdir], 'puppet', 'etc')
    flags = " --bindir=#{settings[:hiera_bindir]} \
              --sitelibdir=#{settings[:hiera_libdir]} \
              --ruby=#{File.join(settings[:ruby_bindir], 'ruby')} "
  end

  pkg.install do
    ["#{settings[:host_ruby]} install.rb \
    --configs \
    --configdir=#{configdir} \
    --man \
    --mandir=#{settings[:mandir]} \
    --no-batch-files \
    #{flags}"]
  end

  pkg.install_file ".gemspec", "#{settings[:gem_home]}/specifications/#{pkg.get_name}.gemspec" unless platform.is_windows?

  pkg.configfile File.join(configdir, 'hiera.yaml')

  if platform.is_windows?
    pkg.add_source("file://resources/files/windows/hiera.bat", sum: "bbe0a513808af61ed9f4b57463851326")
    pkg.install_file "../hiera.bat", "#{settings[:link_bindir]}/hiera.bat"
  else
    pkg.add_source("file://resources/files/hiera.sh")
    pkg.install_file "../hiera.sh", "#{settings[:link_bindir]}/hiera", mode: "755", owner: "root", group: "root"
  end

  if platform.is_windows?
    pkg.directory File.join(settings[:puppet_codedir], 'hieradata')
  else
    pkg.directory File.join(settings[:puppet_codedir], 'environments', 'production', 'hieradata')
  end

  pkg.add_preinstall_action ["upgrade"], ["if [ -e #{File.join(settings[:puppet_codedir], 'hiera.yaml')} ]; then cp #{File.join(settings[:puppet_codedir], 'hiera.yaml')} #{File.join(settings[:puppet_codedir], 'hiera.yaml.pkg-old')}; fi"]
  pkg.add_postinstall_action ["upgrade"], ["if [ -e #{File.join(settings[:puppet_codedir], 'hiera.yaml.pkg-old')} ]; then mv #{File.join(settings[:puppet_codedir], 'hiera.yaml.pkg-old')} #{File.join(settings[:puppet_codedir], 'hiera.yaml')}; fi"]
end
