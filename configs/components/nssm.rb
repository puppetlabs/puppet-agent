component "nssm" do |pkg, settings, platform|
  pkg.version "2.24"
  pkg.md5sum "b2edd0e4a7a7be9d157c0da0ef65b1bc"
  pkg.url "https://nssm.cc/release/nssm-#{pkg.get_version}.zip"

  # Because we're unpacking a zip archive, we need to set the path to the executable.
  # We don't automatically have this set on windows, unfortunately. We need to set the
  # path to have access to 7za.
  pkg.environment "PATH" => "/cygdrive/c/ProgramData/chocolatey/tools:$$PATH" if platform.is_windows?

  win_arch = platform.architecture == "x64" ? "win64" : "win32"

  pkg.install_file "nssm-2.24/#{win_arch}/nssm.exe", "#{settings[:service_dir]}/nssm.exe"
end
