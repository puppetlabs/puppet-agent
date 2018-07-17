source ENV['GEM_SOURCE'] || "https://rubygems.org"

def location_for(place)
  if place =~ /^(git[:@][^#]*)#(.*)/
    [{ :git => $1, :branch => $2, :require => false }]
  elsif place =~ /^file:\/\/(.*)/
    ['>= 0', { :path => File.expand_path($1), :require => false }]
  else
    [place, { :require => false }]
  end
end

gem 'vanagon', *location_for(ENV['VANAGON_LOCATION'] || '~> 0.15.11')
gem 'packaging', *location_for(ENV['PACKAGING_LOCATION'] || '~> 0.99.8')
gem 'artifactory'
gem 'rake'
gem 'json'
gem 'octokit'
gem 'rubocop', "~> 0.34.2"
