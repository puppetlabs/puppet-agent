project "puppet-agent" do |proj|
  # puppet-agent inherits most build settings from puppetlabs/puppet-runtime:
  # - Modifications to global settings like flags and target directories should be made in puppet-runtime.
  # - Settings included in this file should apply only to local components in this repository.
  runtime_details = JSON.parse(File.read(File.join(File.dirname(__FILE__), '..', 'components/puppet-runtime.json')))
  runtime_tag = runtime_details['ref'][/refs\/tags\/(.*)/, 1]
  raise "Unable to determine a tag for puppet-runtime (given #{runtime_details['ref']})" unless runtime_tag
  proj.inherit_settings 'agent-runtime-master', runtime_details['url'], runtime_tag

  platform = proj.get_platform

  # (PA-678) pe-r10k versions prior to 2.5.0.0 ship gettext gems.
  # Since we also ship those gems as part of puppet-agent
  # at present, we need to conflict with pe-r10k < 2.5.0.0
  proj.conflicts "pe-r10k", "2.5.0.0"

  # Project level settings our components will care about
  if platform.is_windows?
    proj.setting(:company_name, "Puppet Inc")
    proj.setting(:pl_company_name, "Puppet Labs")
    proj.setting(:common_product_id, "PuppetInstaller")
    proj.setting(:puppet_service_name, "puppet")
    proj.setting(:upgrade_code, "2AD3D11C-61B3-4710-B106-B4FDEC5FA358")
    if platform.architecture == "x64"
      proj.setting(:product_name, "Puppet Agent (64-bit)")
      proj.setting(:win64, "yes")
      proj.setting(:RememberedInstallDirRegKey, "RememberedInstallDir64")
    else
      proj.setting(:product_name, "Puppet Agent")
      proj.setting(:win64, "no")
      proj.setting(:RememberedInstallDirRegKey, "RememberedInstallDir")
    end
    proj.setting(:links, {
        :HelpLink => "http://puppet.com/services/customer-support",
        :CommunityLink => "http://puppet.com/community",
        :ForgeLink => "http://forge.puppet.com",
        :NextStepLink => "https://docs.puppet.com/pe/latest/quick_start_install_agents_windows.html",
        :ManualLink => "https://docs.puppet.com/puppet/latest/reference",
      })
    proj.setting(:UI_exitdialogtext, "Manage your first resources on this node, explore the Puppet community and get support using the shortcuts in the Documentation folder of your Start Menu.")
    proj.setting(:LicenseRTF, "wix/license/LICENSE.rtf")

    # Directory IDs
    proj.setting(:bindir_id, "bindir")

    # We build for windows not in the final destination, but in the paths that correspond
    # to the directory ids expected by WIX. This will allow for a portable installation (ideally).
    proj.setting(:facter_root, File.join(proj.install_root, "facter"))
    proj.setting(:hiera_root, File.join(proj.install_root, "hiera"))
    proj.setting(:hiera_bindir, File.join(proj.hiera_root, "bin"))
    proj.setting(:hiera_libdir, File.join(proj.hiera_root, "lib"))
    proj.setting(:pxp_root, File.join(proj.install_root, "pxp-agent"))
    proj.setting(:service_dir, File.join(proj.install_root, "service"))
    proj.setting(:ruby_dir, File.join(proj.install_root, "sys/ruby"))
    proj.setting(:ruby_bindir, File.join(proj.ruby_dir, "bin"))
  end

  proj.setting(:puppet_configdir, File.join(proj.sysconfdir, 'puppet'))
  proj.setting(:puppet_codedir, File.join(proj.sysconfdir, 'code'))

  # Target directory for vendor modules
  proj.setting(:module_vendordir, File.join(proj.prefix, 'vendor_modules'))

  # Used to construct download URLs for forge modules in _base-module.rb
  proj.setting(:forge_download_baseurl, "https://forge.puppet.com/v3/files")

  proj.description "The Puppet Agent package contains all of the elements needed to run puppet, including ruby, facter, and hiera."
  proj.version_from_git
  proj.write_version_file File.join(proj.prefix, 'VERSION')
  proj.license "See components"
  proj.vendor "Puppet Labs <info@puppetlabs.com>"
  proj.homepage "https://www.puppetlabs.com"
  proj.target_repo "PC1"

  if platform.is_solaris?
    proj.identifier "puppetlabs.com"
  elsif platform.is_macos?
    proj.identifier "com.puppetlabs"
  end

  # For some platforms the default doc location for the BOM does not exist or is incorrect - move it to specified directory
  if platform.name =~ /cisco-wrlinux/
    proj.bill_of_materials File.join(proj.datadir, "doc")
  end

  # Set package version, for use by Facter in creating the AIO_AGENT_VERSION fact.
  proj.setting(:package_version, proj.get_version)

  # First our stuff
  proj.component "puppet"
  proj.component "facter"
  proj.component "hiera"
  proj.component "leatherman"
  proj.component "cpp-hocon"
  proj.component "cpp-pcp-client"
  proj.component "pxp-agent"
  proj.component "libwhereami"

  # Then the dependencies
  # Provides augeas, curl, libedit, libxml2, libxslt, openssl, puppet-ca-bundle, ruby and rubygem-*
  proj.component "puppet-runtime"
  proj.component "nssm" if platform.is_windows?
  proj.component "rubygem-puppet-resource_api"

  # These utilites don't really work on unix
  if platform.is_linux?
    proj.component "virt-what"
    proj.component "dmidecode" unless platform.architecture =~ /ppc64(?:le|el)/
    proj.component "shellpath"
  end

  proj.component "runtime"

  # Windows doesn't need these wrappers, only unix platforms
  unless platform.is_windows?
    proj.component "wrapper-script"
  end

  # Components only applicable on OSX
  if platform.is_macos?
    proj.component "cfpropertylist"
  end

  # Vendored modules
  proj.component "module-puppetlabs-maillist_core"
  proj.component "module-puppetlabs-mailalias_core"
  proj.component "module-puppetlabs-nagios_core"

  proj.directory proj.install_root
  proj.directory proj.prefix
  proj.directory proj.sysconfdir
  proj.directory proj.link_bindir
  proj.directory proj.logdir unless platform.is_windows?
  proj.directory proj.piddir unless platform.is_windows?
  if platform.is_windows? || platform.is_macos?
    proj.directory proj.bindir
  end

  proj.timeout 7200 if platform.is_windows?
end
