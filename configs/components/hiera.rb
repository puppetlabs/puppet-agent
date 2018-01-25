component "hiera" do |pkg, settings, platform|
  pkg.load_from_json('configs/components/hiera.json')

  pkg.build_requires 'puppet-runtime' # Provides ruby and rubygem-deep-merge
  pkg.replaces 'hiera', '2.0.0'
  pkg.provides 'hiera', '2.0.0'

  pkg.replaces 'pe-hiera'

  # Even though puppet's ruby comes from the runtime, we still need a ruby to build hiera with on these platforms:
  if platform.architecture == "sparc"
    if platform.os_version == "10"
      # ruby1.8 is not new enough to successfully cross-compile ruby 2.1.x (it doesn't understand the --disable-gems flag)
      pkg.build_requires 'ruby20'
    elsif platform.os_version == "11"
      pkg.build_requires 'pl-ruby'
    end
  elsif platform.is_cross_compiled_linux?
    pkg.build_requires 'pl-ruby'
  end

  configdir = settings[:puppet_configdir]
  flags = " --bindir=#{settings[:bindir]} \
            --sitelibdir=#{settings[:ruby_vendordir]} \
            --ruby=#{File.join(settings[:bindir], 'ruby')} "

  if platform.is_windows?
    pkg.add_source("file://resources/files/windows/hiera.bat", sum: "bbe0a513808af61ed9f4b57463851326")
    configdir = File.join(settings[:sysconfdir], 'puppet', 'etc')
    pkg.install_file "../hiera.bat", "#{settings[:link_bindir]}/hiera.bat"
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
    --no-configs \
    #{flags}"]
  end

  pkg.install_file ".gemspec", "#{settings[:gem_home]}/specifications/#{pkg.get_name}.gemspec" unless platform.is_windows?
end
