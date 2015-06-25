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

gem 'vanagon', *vanagon_location_for(ENV['VANAGON_LOCATION'] || '~> 0.3.4')
gem 'packaging', '~> 0.4', :github => 'puppetlabs/packaging'
