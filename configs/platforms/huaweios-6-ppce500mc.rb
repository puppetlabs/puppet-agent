platform "huaweios-6-ppce500mc" do |plat|
  plat.servicedir "/etc/init.d"
  plat.defaultdir "/etc/default"
  plat.servicetype "sysv"

  # This is how we clean up our last build since we don't have a pooler image
  plat.provision_with "rm -rf /opt/pl-build-tools /opt/puppetlabs /etc/puppetlabs /var/log/puppetlabs /var/tmp/root-root /var/tmp/rpm /var/tmp/tmp.* /home/root/*.jam"
end
