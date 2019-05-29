NAMESPACE ?= puppet
git_describe = $(shell git describe)
vcs_ref := $(shell git rev-parse HEAD)
build_date := $(shell date -u +%FT%T)
hadolint_available := $(shell hadolint --help > /dev/null 2>&1; echo $$?)
hadolint_command := hadolint --ignore DL3008 --ignore DL3018 --ignore DL4000 --ignore DL4001
hadolint_container := hadolint/hadolint:latest
makefile_path := $(abspath $(lastword $(MAKEFILE_LIST)))
makefile_dir := $(dir $(makefile_path))
version = $(shell echo $(git_describe) | sed 's/-.*//')
dockerfile := Dockerfile

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
	@docker build --pull --build-arg vcs_ref=$(vcs_ref) --build-arg build_date=$(build_date) --build-arg version=$(version) --file puppet-agent-ubuntu/$(dockerfile) --tag $(NAMESPACE)/puppet-agent-ubuntu:$(version) puppet-agent-ubuntu
	@docker tag $(NAMESPACE)/puppet-agent-ubuntu:$(version) $(NAMESPACE)/puppet-agent:$(version)
	@docker build --pull --build-arg vcs_ref=$(vcs_ref) --build-arg build_date=$(build_date) --build-arg version=$(version) --file puppet-agent-alpine/$(dockerfile) --tag $(NAMESPACE)/puppet-agent-alpine:$(version) $(makefile_dir)/..
ifeq ($(IS_LATEST),true)
	@docker tag $(NAMESPACE)/puppet-agent-ubuntu:$(version) $(NAMESPACE)/puppet-agent-ubuntu:latest
	@docker tag $(NAMESPACE)/puppet-agent-ubuntu:$(version) $(NAMESPACE)/puppet-agent:latest
	@docker tag $(NAMESPACE)/puppet-agent-alpine:$(version) $(NAMESPACE)/puppet-agent-alpine:latest
endif

test: prep
	@bundle install --path .bundle/gems
	@PUPPET_TEST_DOCKER_IMAGE=$(NAMESPACE)/puppet-agent-ubuntu:$(version) bundle exec rspec spec
	@PUPPET_TEST_DOCKER_IMAGE=$(NAMESPACE)/puppet-agent-alpine:$(version) bundle exec rspec spec

publish: prep
	@docker push $(NAMESPACE)/puppet-agent-ubuntu:$(version)
	@docker push $(NAMESPACE)/puppet-agent:$(version)
	@docker push $(NAMESPACE)/puppet-agent-alpine:$(version)
ifeq ($(IS_LATEST),true)
	@docker push $(NAMESPACE)/puppet-agent-ubuntu:latest
	@docker push $(NAMESPACE)/puppet-agent:latest
	@docker push $(NAMESPACE)/puppet-agent-alpine:latest
endif

.PHONY: lint build test publish
