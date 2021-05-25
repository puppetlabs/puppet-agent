platform "debian-9-amd64" do |plat|
  plat.inherit_from_default
  plat.servicetype "sysv", servicedir: "/etc/init.d"
end
