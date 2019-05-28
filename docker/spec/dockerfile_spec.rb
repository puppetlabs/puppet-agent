describe 'puppet-agent' do
  include Pupperware::SpecHelpers

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
    result = run_command("docker run --detach #{@image} apply -e \"notify { 'test': }\"")
    container = result[:stdout].chomp
    wait_on_container_exit(container)
    expect(get_container_exit_code(container)).to eq(0)
    emit_log(container)
    teardown_container(container)
  end

  it 'should be able to run facter' do
    result = run_command("docker run --detach --entrypoint facter #{@image} is_virtual")
    container = result[:stdout].chomp
    wait_on_container_exit(container)
    expect(get_container_exit_code(container)).to eq(0)
    emit_log(container)
    teardown_container(container)
  end
end
