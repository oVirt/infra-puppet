r10k=bundle exec r10k

.PHONY: modules clean

modules:
	$(r10k) puppetfile install

clean:
	$(r10k) puppetfile purge
