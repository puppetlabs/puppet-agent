component "facter" do |pkg, settings, platform|
  pkg.load_from_json('configs/components/facter.json')

  pkg.build_requires 'puppet-runtime' # Provides ruby and rubygem-deep-merge
  pkg.build_requires "pl-ruby-patch"

  flags = " --bindir=#{settings[:bindir]} \
            --sitelibdir=#{settings[:ruby_vendordir]} \
            --mandir=#{settings[:mandir]} \
            --ruby=#{File.join(settings[:bindir], 'ruby')} "

  if platform.is_windows?
    pkg.add_source("file://resources/files/windows/facter.bat", sum: "1521ec859c1ec981a088de5ebe2b270c")
    pkg.install_file "../facter.bat", "#{settings[:link_bindir]}/facter.bat"
  end

  pkg.install do
    ["#{settings[:host_ruby]} install.rb \
    --no-batch-files \
    --no-configs \
    #{flags}"]
  end

  pkg.install_file "facter.gemspec", "#{settings[:gem_home]}/specifications/#{pkg.get_name}-#{pkg.get_version_forced}.gemspec" unless platform.is_windows?

end
