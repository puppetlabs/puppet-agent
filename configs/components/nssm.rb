component "nssm" do |pkg, settings, platform|
  pkg.load_from_json("configs/components/nssm.json")

  # Because we're unpacking a zip archive, we need to set the path to the executable.
  # We don't automatically have this set on windows, unfortunately. We need to set the
  # path to have access to 7za.
  pkg.environment "PATH" => "/cygdrive/c/ProgramData/chocolatey/tools:$$PATH" if platform.is_windows?

  win_arch = platform.architecture == "x64" ? "win64" : "win32"

  pkg.install_file "#{win_arch}/nssm.exe", "#{settings[:bindir]}/nssm.exe"
end
