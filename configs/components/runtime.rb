# This component exists to link in the gcc and stdc++ runtime libraries as well as libssp.
component "runtime" do |pkg, settings, platform|
  if platform.is_solaris?
    pkg.build_requires "http://pl-build-tools.delivery.puppetlabs.net/solaris/10/pl-gcc-4.8.2.#{platform.architecture}.pkg.gz"
    pkg.build_requires "http://pl-build-tools.delivery.puppetlabs.net/solaris/10/pl-binutils-2.25.#{platform.architecture}.pkg.gz"
  end

  if platform.architecture == "sparc"
    pkg.install_file File.join("/opt/pl-build-tools", settings[:platform_triple], "/lib/libstdc++.so.6.0.18"), "/opt/puppetlabs/puppet/lib/libstdc++.so.6.0.18"
    pkg.install_file File.join("/opt/pl-build-tools", settings[:platform_triple], "/lib/libgcc_s.so.1"), "/opt/puppetlabs/puppet/lib/libgcc_s.so.1"
    pkg.install_file File.join("/opt/pl-build-tools", settings[:platform_triple], "/lib/libssp.so.0.0.0"), "/opt/puppetlabs/puppet/lib/libssp.so.0.0.0"
  else
    pkg.install_file "/opt/pl-build-tools/lib/libstdc++.so.6.0.18", "/opt/puppetlabs/puppet/lib/libstdc++.so.6.0.18"
    pkg.install_file "/opt/pl-build-tools/lib/libgcc_s.so.1", "/opt/puppetlabs/puppet/lib/libgcc_s.so.1"
    pkg.install_file "/opt/pl-build-tools/lib/libssp.so.0.0.0", "/opt/puppetlabs/puppet/lib/libssp.so.0.0.0"
  end

  pkg.link "/opt/puppetlabs/puppet/lib/libstdc++.so.6.0.18", "/opt/puppetlabs/puppet/lib/libstdc++.so"
  pkg.link "/opt/puppetlabs/puppet/lib/libstdc++.so.6.0.18", "/opt/puppetlabs/puppet/lib/libstdc++.so.6"
  pkg.link "/opt/puppetlabs/puppet/lib/libgcc_s.so.1", "/opt/puppetlabs/puppet/lib/libgcc_s.so"
  pkg.link "/opt/puppetlabs/puppet/lib/libssp.so.0.0.0", "/opt/puppetlabs/puppet/lib/libssp.so.0"
  pkg.link "/opt/puppetlabs/puppet/lib/libssp.so.0.0.0", "/opt/puppetlabs/puppet/lib/libssp.so"
end
