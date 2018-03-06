# This component simply installs a cmake toolchain file for use when building
# using OS native build toolchains. This is needed before the configure step on
# leatherman, which is why you can't use a `pkg.install_file` in the leatherman
# component to make this work.
#
component "toolchain" do |pkg, settings, platform|
  pkg.add_source "file://resources/files/arm/debian-armhf-toolchain"
  pkg.install_file "debian-armhf-toolchain", "#{settings[:datadir]}/doc"
end
