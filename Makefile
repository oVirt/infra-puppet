r10k=bundle exec r10k
bundle_install=bundle install --path vendor/bundle

.PHONY: modules clean test-bundle deployment-bundle check-patch

test-bundle: Gemfile
	$(bundle_install) --without deployment

deployment-bundle: Gemfile
	$(bundle_install) --without test

modules: deployment-bundle
	$(r10k) puppetfile install

clean: deployment-bundle
	$(r10k) puppetfile purge
