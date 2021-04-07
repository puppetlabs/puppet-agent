source ENV['GEM_SOURCE'] || "https://rubygems.org"

gem 'pupperware',
  :git => 'https://github.com/puppetlabs/pupperware.git',
  :ref => 'main',
  :glob => 'gem/*.gemspec'

group :test do
  gem 'rspec'
  gem 'rspec_junit_formatter'
end
