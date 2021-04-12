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


docker: install-deps build
	@cp pkg/fluent-plugin-*.gem docker
	@mkdir -p docker/licenses
	@cp -rp LICENSE docker/licenses/
	@docker build --no-cache --pull --build-arg VERSION=$(VERSION) --build-arg NODEJS_VERSION=$(NODEJS_VERSION) -t abhishek138/fluentd-hec:$(VERSION) ./docker	
push:
        if [ "${TRAVIS_CPU_ARCH}" == "arm64" ]; then
         @docker tag abhishek138/fluentd-hec:$(VERSION) abhishek138/fluentd-hec:$(VERSION)_arm64;
         @docker push abhishek138/fluentd-hec:$(VERSION)_arm64;
        else
         @docker push abhishek138/fluentd-hec:$(VERSION);
      fi	
	   

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
