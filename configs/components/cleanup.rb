# This component exists only to remove unnecessary files that bloat the final puppet-agent package.
component "cleanup" do |pkg, settings, platform|
  # This component must depend on all other C++ components in order to be
  # executed last, after they all finish building.
  pkg.build_requires "cpp-pcp-client"
  pkg.build_requires "cpp-hocon"
  pkg.build_requires "facter"
  pkg.build_requires "leatherman"
  pkg.build_requires "libwhereami"
  pkg.build_requires "pxp-agent"

  unless settings[:dev_build]
    # Unless the settings specify that this is a development build, remove
    # unneeded header files (boost headers, for example, increase the size of
    # the package to an unacceptable degree).
    #
    # Note that:
    # - Ruby is not in this list because its headers are required to build native
    #   extensions for gems.
    # - OpenSSL is not in this list because its headers are required to build
    #   other libraries (e.g. libssh2) in other projects that rely on
    #   puppet-agent (e.g. pe-r10k-vanagon).
    unwanted_headers = ["augeas.h", "boost", "cpp-pcp-client", "curl", "fa.h",
                        "facter", "hocon", "leatherman", "libexslt", "libxml2",
                        "libxslt", "whereami", "yaml-cpp"]

    # We need a full path on windows because /usr/bin is not in the PATH at this point
    rm = platform.is_windows? ? '/usr/bin/rm' : 'rm'

    pkg.install do
      [
        unwanted_headers.map { |h| "#{rm} -rf #{settings[:includedir]}/#{h}" },
        # Also remove OpenSSL manpages
        "#{rm} -rf #{settings[:prefix]}/ssl/man",
      ]
    end
  end
end
