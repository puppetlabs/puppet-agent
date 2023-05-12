platform 'osx-11-x86_64' do |plat|
  plat.inherit_from_default
  # PA-5471 override default 'osx' directory
  plat.output_dir File.join('apple', '11', 'puppet8', 'x86_64')
end
