component "ca-cert" do |pkg, settings, platform|
  pkg.version "2015-07-31"
  pkg.md5sum "a59fa24705ed0be7ff6b00d5f3aefd5c"
  pkg.url "file://files/cert.pem.txt"
  pkg.install_file("./cert.pem.txt", "#{settings[:prefix]}/ssl/cert.pem")
end
