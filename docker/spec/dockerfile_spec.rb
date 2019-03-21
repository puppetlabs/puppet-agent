describe 'puppet-agent' do
  include Helpers

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
    result = run_command("docker run --rm #{@image} apply -e \"notify { 'test': }\"")
    puts result[:stdout] unless result[:status].exitstatus == 0
    expect(result[:status].exitstatus).to eq(0)
  end

  it 'should be able to run facter' do
    result = run_command("docker run --rm --entrypoint facter #{@image} is_virtual")
    expect(result[:status].exitstatus).to eq(0)
    expect(result[:stdout].chomp).to eq('true')
  end
end
