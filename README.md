oVirt Infra Puppet
==================

This repository contains puppet manifests used for the oVirt infra.
Please submit patches to https://gerrit.ovirt.org/

Layout
======

* Gemfile
* Makefile
* Puppetfile
* README.md
* modules/
* site/
 * ovirt_infra/

The modules directory is generated and in .gitignore. It is filled based on the
Puppetfile. All local modules should be in site. For development convenience,
there's also a Gemfile and a Makefile.

Using r10k
==========

Since we need r10k, we can use the Gemfile with bundler:

    bundle install

To generate the modules directory, we use r10k:

    bundle exec r10k puppetfile install

You can also purge old modules:

    bundle exec r10k puppetfile purge

For convenience, the last two steps can be done using make:

    make
