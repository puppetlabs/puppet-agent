platform "sles-15-x86_64" do |plat|
  plat.servicedir "/usr/lib/systemd/system"
  plat.defaultdir "/etc/sysconfig"
  plat.servicetype "systemd"

  plat.provision_with "zypper -n --no-gpg-checks install -y aaa_base autoconf automake rsync gcc gcc-c++ make rpm-build libboost_atomic1_66_0-devel libboost_chrono1_66_0-devel libboost_container1_66_0-devel libboost_date_time1_66_0-devel libboost_filesystem1_66_0-devel libboost_graph1_66_0-devel libboost_iostreams1_66_0-devel libboost_locale1_66_0-devel libboost_log1_66_0-devel libboost_math1_66_0-devel libboost_program_options1_66_0-devel libboost_random1_66_0-devel libboost_regex1_66_0-devel libboost_serialization1_66_0-devel libboost_signals1_66_0-devel libboost_system1_66_0-devel libboost_test1_66_0-devel libboost_thread1_66_0-devel libboost_timer1_66_0-devel libboost_wave1_66_0-devel gettext-tools cmake yaml-cpp-devel"
  plat.install_build_dependencies_with "zypper -n --no-gpg-checks install -y"
  plat.vmpooler_template "sles-15-x86_64"
end
