NAMESPACE ?= puppet
git_describe = $(shell git describe)
vcs_ref := $(shell git rev-parse HEAD)
build_date := $(shell date -u +%FT%T)
hadolint_available := $(shell hadolint --help > /dev/null 2>&1; echo $$?)
hadolint_command := hadolint
hadolint_container := hadolint/hadolint:latest
alpine_version := 3.9
ubuntu_version := 18.04
export BUNDLE_PATH = $(PWD)/.bundle/gems
export BUNDLE_BIN = $(PWD)/.bundle/bin
export GEMFILE = $(PWD)/Gemfile
export DOCKER_BUILDKIT = 1

version = $(shell echo $(git_describe) | sed 's/-.*//')
dockerfile := Dockerfile
makefile_path := $(abspath $(lastword $(MAKEFILE_LIST)))
makefile_dir := $(dir $(makefile_path))
LATEST_VERSION ?= latest

prep:
	@git fetch --unshallow ||:
	@git fetch origin 'refs/tags/*:refs/tags/*'

lint:
ifeq ($(hadolint_available),0)
	@$(hadolint_command) puppet-agent-ubuntu/$(dockerfile)
	@$(hadolint_command) puppet-agent-alpine/$(dockerfile)
else
	@docker pull $(hadolint_container)
	@docker run --rm -v $(PWD)/puppet-agent-ubuntu/$(dockerfile):/Dockerfile -i $(hadolint_container) $(hadolint_command) Dockerfile
	@docker run --rm -v $(PWD)/puppet-agent-alpine/$(dockerfile):/Dockerfile -i $(hadolint_container) $(hadolint_command) Dockerfile
endif

build: prep
	docker pull alpine:$(alpine_version)
	docker pull ubuntu:$(ubuntu_version)
	docker build ${DOCKER_BUILD_FLAGS} --build-arg vcs_ref=$(vcs_ref) --build-arg build_date=$(build_date) --build-arg version=$(version) --file puppet-agent-ubuntu/$(dockerfile) --tag $(NAMESPACE)/puppet-agent-ubuntu:$(version) puppet-agent-ubuntu
	@docker tag $(NAMESPACE)/puppet-agent-ubuntu:$(version) $(NAMESPACE)/puppet-agent:$(version)
	docker build ${DOCKER_BUILD_FLAGS} --build-arg alpine_version=$(alpine_version) --build-arg vcs_ref=$(vcs_ref) --build-arg build_date=$(build_date) --build-arg version=$(version) --file puppet-agent-alpine/$(dockerfile) --tag $(NAMESPACE)/puppet-agent-alpine:$(version) $(PWD)/..
ifeq ($(IS_LATEST),true)
	@docker tag $(NAMESPACE)/puppet-agent-ubuntu:$(version) $(NAMESPACE)/puppet-agent-ubuntu:$(LATEST_VERSION)
	@docker tag $(NAMESPACE)/puppet-agent-ubuntu:$(version) $(NAMESPACE)/puppet-agent:$(LATEST_VERSION)
	@docker tag $(NAMESPACE)/puppet-agent-alpine:$(version) $(NAMESPACE)/puppet-agent-alpine:$(LATEST_VERSION)
endif

test: prep
	@bundle install --path $$BUNDLE_PATH --gemfile $$GEMFILE --with test
	@bundle update
	@PUPPET_TEST_DOCKER_IMAGE=$(NAMESPACE)/puppet-agent-ubuntu:$(version) \
		bundle exec --gemfile $$GEMFILE rspec spec
	@PUPPET_TEST_DOCKER_IMAGE=$(NAMESPACE)/puppet-agent-alpine:$(version) \
		bundle exec --gemfile $$GEMFILE rspec spec

publish: prep
	@docker push $(NAMESPACE)/puppet-agent-ubuntu:$(version)
	@docker push $(NAMESPACE)/puppet-agent:$(version)
	@docker push $(NAMESPACE)/puppet-agent-alpine:$(version)
ifeq ($(IS_LATEST),true)
	@docker push $(NAMESPACE)/puppet-agent-ubuntu:$(LATEST_VERSION)
	@docker push $(NAMESPACE)/puppet-agent:$(LATEST_VERSION)
	@docker push $(NAMESPACE)/puppet-agent-alpine:$(LATEST_VERSION)
endif

.PHONY: lint build test publish
