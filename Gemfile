source 'https://rubygems.org'

def vanagon_location_for(place)
  if place =~ /^(git[:@][^#]*)#(.*)/
    [{ :git => $1, :branch => $2, :require => false }]
  elsif place =~ /^file:\/\/(.*)/
    ['>= 0', { :path => File.expand_path($1), :require => false }]
  elsif place =~ /(\d+\.\d+\.\d+)/
    [$1, {:git => 'git@github.com:puppetlabs/vanagon', :tag => $1}]
  end
end

gem 'vanagon', '~> 0.3', :git => 'git@github.com:puppetlabs/vanagon', :branch => 'master'
gem 'packaging', '0.4.2', :github => 'puppetlabs/packaging', :tag => '0.4.2'
