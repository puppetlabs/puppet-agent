platform "solaris-11-i386" do |plat|
  plat.inherit_from_default
  plat.output_dir File.join("solaris", "11", "puppet6")
end
