VERSION := $(shell sh -c 'cat VERSION')
NODEJS_VERSION := 14.15.1

clean_pkg: 
	@rm -rf pkg/* docker/*.gem 

clean_gems:
	@rm -rf docker/gem/ docker/gems/

clean: clean_pkg clean_gems
	@rm -rf docker/licenses

build: clean_pkg 
	@bundle exec rake build

install_buildx: mkdir -p ~/.docker/cli-plugins
                @wget -O - https://github.com/docker/buildx/releases/download/v0.5.1/buildx-v0.5.1.linux-amd64 > ~/.docker/cli-plugins/docker-buildx
                @chmod a+x ~/.docker/cli-plugins/docker-buildx
                @docker run --rm --privileged docker/binfmt:a7996909642ee92942dcd6cff44b9b95f08dad64
                @docker buildx create --use --name mybuilder	

docker: install-deps build install_buildx
	@cp pkg/fluent-plugin-*.gem docker
	@mkdir -p docker/licenses
	@cp -rp LICENSE docker/licenses/
	#@docker build --no-cache --pull --build-arg VERSION=$(VERSION) --build-arg NODEJS_VERSION=$(NODEJS_VERSION) -t splunk/fluentd-hec:$(VERSION) ./docker
	@docker buildx build --no-cache --pull --build-arg VERSION=$(VERSION) --build-arg NODEJS_VERSION=$(NODEJS_VERSION) --platform linux/amd64,linux/arm64 -t abhishek138/fluentd-hec:latest ./docker  --push .;
        #@docker buildx build --platform linux/amd64,linux/arm64 -t abhishek138/fluentd-hec:latest ./docker -t abhishek138/fluentd-hec:latest ./docker --push .;
        

unit-test:
	@bundle exec rake test

install-deps:
	@gem install bundler
	@bundle update --bundler
	@bundle install

unpack: build
	@cp pkg/fluent-plugin-*.gem docker
	@mkdir -p docker/gem
	@rm -rf docker/gem/*
	@gem unpack docker/fluent-plugin-*.gem --target docker/gem
	@cd docker && bundle install


unit-test:
	@bundle exec rake test

install-deps:
	@gem install bundler
	@bundle update --bundler
	@bundle install

unpack: build
	@cp pkg/fluent-plugin-*.gem docker
	@mkdir -p docker/gem
	@rm -rf docker/gem/*
	@gem unpack docker/fluent-plugin-*.gem --target docker/gem
	@cd docker && bundle install
