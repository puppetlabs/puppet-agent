require 'puppet_docker_tools/spec_helper'

describe 'puppet-agent' do
  before(:all) do
    @image = ENV['PUPPET_TEST_DOCKER_IMAGE']
    if @image.nil?
      error_message = <<-MSG
* * * * *
  PUPPET_TEST_DOCKER_IMAGE environment variable must be set so we
  know which image to test against!
* * * * *
      MSG
      fail error_message
    end
  end

  it 'should be able to run a puppet apply' do
    output = `docker run --rm #{@image} apply -e "notify { 'test': }"`
    status = $?
    puts output unless status == 0
    expect(status).to eq(0)
  end

  it 'should be able to run facter' do
    output = `docker run --rm --entrypoint facter #{@image} is_virtual`.chomp
    status = $?
    expect(status).to eq(0)
    expect(output).to eq('true')
  end
end
