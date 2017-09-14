component "libxml2" do |pkg, settings, platform|
  pkg.version "2.9.4"
  pkg.md5sum "ae249165c173b1ff386ee8ad676815f5"
  pkg.url "http://xmlsoft.org/sources/#{pkg.get_name}-#{pkg.get_version}.tar.gz"
  pkg.mirror "http://buildsources.delivery.puppetlabs.net/libxml2-#{pkg.get_version}.tar.gz"
  # CVE-related patches needed until libxml 2.9.5 is released:
  pkg.apply_patch 'resources/patches/libxml2/fix_XPointer_paths_beginning_with_range-to_CVE-2016-5131.patch'
  pkg.apply_patch 'resources/patches/libxml2/fix_comparison_with_root_node_in_xmlXPathCmpNodes.patch'
  pkg.apply_patch 'resources/patches/libxml2/disallow_namespace_nodes_in_XPointer_ranges_CVE-2016-4658.patch'

  if platform.is_aix?
    pkg.environment "PATH", "/opt/pl-build-tools/bin:$(PATH)"
  elsif platform.is_cross_compiled_linux?
    pkg.environment "PATH", "/opt/pl-build-tools/bin:$(PATH):#{settings[:bindir]}"
    pkg.environment "CFLAGS", settings[:cflags]
    pkg.environment "LDFLAGS", settings[:ldflags]
  elsif platform.is_solaris?
    pkg.environment "PATH", "/opt/pl-build-tools/bin:$(PATH):/usr/local/bin:/usr/ccs/bin:/usr/sfw/bin:#{settings[:bindir]}"
    pkg.environment "CFLAGS", settings[:cflags]
    pkg.environment "LDFLAGS", settings[:ldflags]
  elsif platform.is_macos?
    pkg.environment "LDFLAGS", settings[:ldflags]
    pkg.environment "CFLAGS", settings[:cflags]
  else
    pkg.build_requires "make"
    pkg.environment "LDFLAGS", settings[:ldflags]
    pkg.environment "CFLAGS", settings[:cflags]
  end

  pkg.build_requires 'runtime'

  # The system pkg-config has been found to pass incorrect build flags on
  # some (but not all) cross-compiled debian-based platforms:
  if platform.is_cross_compiled? && platform.is_deb?
    pkg.build_requires "pl-pkg-config" unless platform.name =~ /ubuntu-16\.04-ppc64el/
  end

  pkg.configure do
    ["./configure --prefix=#{settings[:prefix]} --without-python #{settings[:host]}"]
  end

  pkg.build do
    ["#{platform[:make]} VERBOSE=1 -j$(shell expr $(shell #{platform[:num_cores]}) + 1)"]
  end

  pkg.install do
    [
      "#{platform[:make]} VERBOSE=1 -j$(shell expr $(shell #{platform[:num_cores]}) + 1) install",
      "rm -rf #{settings[:datadir]}/gtk-doc",
      "rm -rf #{settings[:datadir]}/doc/#{pkg.get_name}*"
    ]
  end

end
