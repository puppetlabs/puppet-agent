component "nssm" do |pkg, settings, platform|
  pkg.version "2.24"
  pkg.md5sum "0fa251d152383ded6850097279291bb0"
  pkg.url "https://nssm.cc/release/nssm-#{pkg.get_version}.zip"

  # Because we're unpacking a zip archive, we need to set the path to the executable.
  # We don't automatically have this set on windows, unfortunately. We need to set the
  # path to have access to 7za.
  pkg.environment "PATH", "$(CHOCOLATEY_TOOLS):$(PATH)" if platform.is_windows?

  win_arch = platform.architecture == "x64" ? "win64" : "win32"

  pkg.install_file "#{win_arch}/nssm.exe", "#{settings[:service_dir]}/nssm.exe"
end
