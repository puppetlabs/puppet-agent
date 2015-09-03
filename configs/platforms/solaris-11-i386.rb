platform "solaris-11-i386" do |plat|
  plat.servicedir "/lib/svc/manifest"
  plat.defaultdir "/lib/svc/method"
  plat.servicetype "smf"
  plat.vcloud_name "solaris-11-x86_64"
  plat.add_build_repository 'http://solaris-11-reposync.delivery.puppetlabs.net:81', 'puppetlabs.com'
  plat.install_build_dependencies_with "pkg install ", " || [[ $? -eq 4 ]]"
end
