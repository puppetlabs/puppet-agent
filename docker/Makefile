git_describe = $(shell git describe)
vcs_ref := $(shell git rev-parse HEAD)
build_date := $(shell date -u +%FT%T)
hadolint_available := $(shell hadolint --help > /dev/null 2>&1; echo $$?)
hadolint_command := hadolint --ignore DL3008 --ignore DL3018 --ignore DL4000 --ignore DL4001 --ignore DL3028
hadolint_container := hadolint/hadolint:latest
makefile_path := $(abspath $(lastword $(MAKEFILE_LIST)))
makefile_dir := $(dir $(makefile_path))
version = $(shell echo $(git_describe) | sed 's/-.*//')
dockerfile := Dockerfile
LATEST_VERSION ?= latest

prep:
	@git fetch --unshallow ||:
	@git fetch origin 'refs/tags/*:refs/tags/*'

lint:
ifeq ($(hadolint_available),0)
	@$(hadolint_command) puppet-agent-ubuntu/$(dockerfile)
else
	@docker pull $(hadolint_container)
	@docker run --rm -v $(PWD)/puppet-agent-ubuntu/$(dockerfile):/Dockerfile -i $(hadolint_container) $(hadolint_command) Dockerfile
endif

build: prep
	@docker build --pull --build-arg vcs_ref=$(vcs_ref) --build-arg build_date=$(build_date) --build-arg version=$(version) --file puppet-agent-ubuntu/$(dockerfile) --tag puppet/puppet-agent-ubuntu:$(version) puppet-agent-ubuntu
	@docker tag puppet/puppet-agent-ubuntu:$(version) puppet/puppet-agent:$(version)
ifeq ($(IS_LATEST),true)
	@docker tag puppet/puppet-agent-ubuntu:$(version) puppet/puppet-agent-ubuntu:$(LATEST_VERSION)
	@docker tag puppet/puppet-agent-ubuntu:$(version) puppet/puppet-agent:$(LATEST_VERSION)
	@docker tag puppet/puppet-agent-alpine:$(version) puppet/puppet-agent-alpine:$(LATEST_VERSION)
endif

test: prep
	@bundle install --path .bundle/gems
	@PUPPET_TEST_DOCKER_IMAGE=puppet/puppet-agent-ubuntu:$(version) bundle exec rspec spec

publish: prep
	@docker push puppet/puppet-agent-ubuntu:$(version)
	@docker push puppet/puppet-agent:$(version)
ifeq ($(IS_LATEST),true)
	@docker push puppet/puppet-agent-ubuntu:$(LATEST_VERSION)
	@docker push puppet/puppet-agent:$(LATEST_VERSION)
	@docker push puppet/puppet-agent-alpine:$(LATEST_VERSION)
endif

.PHONY: lint build test publish
