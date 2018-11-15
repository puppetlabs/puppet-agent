git_describe := $(shell git describe)
vcs_ref := $(shell git rev-parse HEAD)
build_date := $(shell date -u +%FT%T)
hadolint_available := $(shell hadolint --help > /dev/null 2>&1; echo $$?)
hadolint_command := hadolint --ignore DL3008 --ignore DL3018 --ignore DL4000 --ignore DL4001
hadolint_container := hadolint/hadolint:latest
makefile_path := $(abspath $(lastword $(MAKEFILE_LIST)))
makefile_dir := $(dir $(makefile_path))

ifeq ($(IS_NIGHTLY),true)
	dockerfile := Dockerfile.nightly
	version := puppet6-nightly
else
	version := $(shell echo $(git_describe) | sed 's/-.*//')
	dockerfile := Dockerfile
endif


prep:
ifneq ($(IS_NIGHTLY),true)
	@git pull --unshallow > /dev/null 2>&1 ||:
	@git fetch origin 'refs/tags/*:refs/tags/*' > /dev/null 2>&1
endif

lint:
ifeq ($(hadolint_available),0)
	@$(hadolint_command) puppet-agent-ubuntu/$(dockerfile)
ifneq ($(IS_NIGHTLY),true)
	@$(hadolint_command) puppet-agent-alpine/$(dockerfile)
endif
else
	@docker pull $(hadolint_container)
	@docker run --rm -v $(PWD)/puppet-agent-ubuntu/$(dockerfile):/Dockerfile -i $(hadolint_container) $(hadolint_command) Dockerfile
ifneq ($(IS_NIGHTLY),true)
	@docker run --rm -v $(PWD)/puppet-agent-alpine/$(dockerfile):/Dockerfile -i $(hadolint_container) $(hadolint_command) Dockerfile
endif
endif

build: prep
	@docker build --pull --build-arg vcs_ref=$(vcs_ref) --build-arg build_date=$(build_date) --build-arg version=$(version) --file puppet-agent-ubuntu/$(dockerfile) --tag puppet/puppet-agent-ubuntu:$(version) puppet-agent-ubuntu
	@docker tag puppet/puppet-agent-ubuntu:$(version) puppet/puppet-agent:$(version)
ifneq ($(IS_NIGHTLY),true)
	@docker build --pull --build-arg vcs_ref=$(vcs_ref) --build-arg build_date=$(build_date) --build-arg version=$(version) --file puppet-agent-alpine/$(dockerfile) --tag puppet/puppet-agent-alpine:$(version) $(makefile_dir)/..
endif
ifeq ($(IS_LATEST),true)
	@docker tag puppet/puppet-agent-ubuntu:$(version) puppet/puppet-agent-ubuntu:latest
	@docker tag puppet/puppet-agent-ubuntu:$(version) puppet/puppet-agent:latest
	@docker tag puppet/puppet-agent-alpine:$(version) puppet/puppet-agent-alpine:latest
endif

test: prep
	@bundle install --path .bundle/gems
	@PUPPET_TEST_DOCKER_IMAGE=puppet/puppet-agent-ubuntu:$(version) bundle exec rspec puppet-agent-ubuntu/spec
ifneq ($(IS_NIGHTLY),true)
	@PUPPET_TEST_DOCKER_IMAGE=puppet/puppet-agent-alpine:$(version) bundle exec rspec puppet-agent-alpine/spec
endif

publish: prep
	@docker push puppet/puppet-agent-ubuntu:$(version)
	@docker push puppet/puppet-agent:$(version)
ifneq ($(IS_NIGHTLY),true)
	@docker push puppet/puppet-agent-alpine:$(version)
endif
ifeq ($(IS_LATEST),true)
	@docker push puppet/puppet-agent-ubuntu:latest
	@docker push puppet/puppet-agent:latest
	@docker push puppet/puppet-agent-alpine:latest
endif

.PHONY: lint build test publish
