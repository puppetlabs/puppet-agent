platform "osx-11-arm64" do |plat|
  plat.inherit_from_default
  plat.output_dir File.join('apple', '11', 'puppet7', 'arm64')
end
