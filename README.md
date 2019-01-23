# Overview of genebean/packer-templates

This repo contains my [Packer][packer] templates for building bases boxes used
in [Vagrant][vagrant] and [Docker][docker]. By default it will build the Vagrant
boxes in Virtualbox and Docker format. There are also definitions for VMware boxes
but these are untested due to issues getting Packer and VMware Player to play
nice with each other. The files in the repo are laid out
so that each OS and version combo has a top-level folder. Each os also has a
common folder where shared code lives. Under each OS version folder are
the files needed to build that combo in several different
configurations including:
- `base`: the common base that the boxes below are built on top of
- `nocm`: a setup without any configuration management installed
- `docker-ce`: Docker CE installed and configured
- `puppet-latest`: Latest version of Puppet is installed
- `puppet5`: Puppet 5.x is installed
- `rvm-multi`: RVM with the following Rubys installed:
  - jruby-9.2
  - jruby-9.1
  - 2.6.0
  - 2.5.1 (default)
  - 2.4.1
  - 2.2.1
  - 1.9.3

The base version is a little different than the others. When used for a
virtual machine it does not produce a Vagrant box but rather creates a
VM that is used by all the other builds. The Docker version does produce
an image that is essentially identical to the "nocm" version. This is
done primarily for consistency as the "nocm" version of each is what
will be shared publicly.

Many of the ideas and concepts for these templates have been pulled
from the following two sources:
- [shiguredo/packer-templates][shiguredo/packer-templates] -
  I originally forked this repo but have since reworked it completely based on
  some tricks learned from my next source.
- [puppetlabs/puppetlabs-packer][puppetlabs/puppetlabs-packer] -
  I now utilize an idea gathered from here to build a base VM and then
  separately build each box, adding in needed modifications as needed as part of
  the build process.


# Usage

## Installing Packer

If you're using Homebrew:

```bash
$ brew tap homebrew/binary
$ brew install packer
```

Otherwise, download the latest packer from http://www.packer.io/downloads.html
and unzip the appropriate directory.


## Running Packer

```bash
$ git clone https://github.com/genebean/packer-templates.git
$ cd packer-templates
```

### The `box-versions` file

The build scripts below all reference a file called `box-versions`. This files
simply contains the list of templates that each script should loop over so that
the list is not duplicated between scripts.

### Set the build version to be uploaded

These templates automatically upload the produced boxes so you must define the
box version

```bash
export $VAGRANT_BOX_VERSION=x.y.z
```

_As of now the only way to skip the upload is to edit the JSON files_

### Build all boxes in all folders

```bash
$ ./run-all-builds.sh
```

By default, this will build all boxes by looping over the top
level folders and calling `build-all.sh` in each. If you want
to speed things up a bit you can run all the `build-all.sh`
scripts in parallel like this:

```bash
$ ./run-all-builds.sh -p
```


### Build all boxes in a single folder

```bash
$ cd some-os-version-combo
$ ./build-all.sh
```

### Build one box at a time

```bash
builder=virtualbox
box_prefix=centos-7 # or centos-6
DIR='../centos-commmon'
# base must be built before other templates
$ packer build -force -only=${builder}-base-${box_prefix} -var-file=template-base-vars.json $DIR/template-base.json

box=puppet-latest # or any other template you wish to use
$ packer build -force -only=${builder}-vagrant-${box}-${box_prefix} -var-file=template-std-vars.json $DIR/template-${box}.json
```

### Build for single platform

```bash
# replace "centos-7" with the name of the folder you are in
# replace "puppet" with the type of box you want

# for Virtualbox:
$ ./build.sh vagrant

# for Docker:
$ ./build.sh docker

# for VMware:
$ ./build.sh vmware
```

### Push Docker Images

```bash
cd packer-templates # repo root folder
./docker-tag-n-push.sh x.y.z # version being released
```


### Supported Packer version

This templates was tested using a packer 1.3.3


# Development

If you would like to make new templates or change these to have your name
instead of `genebean` then you will want to take note of the variables
in the templates and build scripts. Below are some details to get you
started.

## Build Scripts

These scripts have just two things you may want to change:

```bash
# this is in all three scripts:
# - build.sh
# - build-all.sh
# - docker-tag-n-push.sh

# this is the first part of each box's name
box_prefix='centos-7'
docker_user='genebean'
os='centos-7'
```

If you are making a new OS and version combo then you will  want to update
the `box_prefix` value. If you want the Docker images to have your name
associated with then then you will want to update `docker_user`.

## Templates

All the templates utilize variables for most things that you might want
to change. These variables are located at the top of the file. Details
specific to each template are below. Remember that any of these can be
updated via the command line also as an argument to `packer`.

### template-base

This template sets things up for all the subsequent builds and has the
following settings:

```bash
"variables": {
  "os": "centos-7",                   # This should match the folder you are in
  "docker_image": "centos:centos7",   # This is the Docker image to base your images on
  "docker_user": "genebean",          # This is the name that will be used when exporting the Docker image
  "build_name": "base",               # This is the name of the template you are in
  "iso_url": "http://[...].iso",      # The url or file path of the ISO to use
  "iso_checksum": "fssafsa"           # The sha1 checksum of the ISO above
}
```

### template-nocm

This template builds a box out of the base system without any further
modifications.

```bash
"variables": {
  "os": "centos-7",                          # This should match the folder you are in
  "docker_image": "genebean/centos-7-base",  # Builds this image based on the base one
  "docker_user": "genebean",                 # This is the name that will be used when exporting the Docker image
  "build_name": "nocm"                       # This is the name of the template you are in
}
```

### template-puppet5 / template-rvm-multi / etc.

These templates build a box out of the base system. They build a box
by running a script during provisioning that has the same name as
the template (`build_name`). All the specialized boxes are built
this way. The only difference in any of these templates is the build
name.

```bash
"variables": {
  "os": "centos-7",                          # This should match the folder you are in
  "docker_image": "genebean/centos-7-base",  # Builds this image based on the base one
  "docker_user": "genebean",                 # This is the name that will be used when exporting the Docker image
  "build_name": "puppet5"                    # This is the name of the template you are in
}
```


## Specialty Templates

These templates are in a slightly different class than the standard ones above:
they do specialize things and may well require extra configuration to work.
They also are not included in `box-versions` which means they are not part of
the `build.sh` or `build-all.sh` scripts.

### template-pebaseline

This template is an extension of the puppet-related templates above that is
designed to work with a Puppet Enterprise installation. During the provisioning
phase this template will install a Puppet agent using the `curl|bash` method,
prompt you to go sign the cert, run puppet twice, and then prompt you to go
purge the node. It will also clean up the machine being built so that it can
easily be renamed and joined back to puppet later. The primary purpose of this
template is to generate an image that can be uploaded to VMware vCenter and used
as a template there.

### upload-vsphere-*

These specialized templates take the output of the corresponding `template-*`,
prep it for upload to vCenter, and then upload it via the vsphere post-processor
to a vCenter. To use this template you must first set several environment
variables. To make this easier there is a `env-vars.sample` in this repository
that you can copy to `env-vars`, fill in as needed, and then source. The file
`env-vars` has been added to the .gitignore file so that it will not be tracked
by version control.


## What's next

The Ubuntu 14.04 folder currently is just a carry-over from the old setup. I
plan to build this one out like the CentOS ones.

Also, I plan to add in Windows templates and, possibly, support for KVM.


[docker]: https://www.docker.com
[shiguredo/packer-templates]: https://github.com/shiguredo/packer-templates
[packer]: https://packer.io
[puppetlabs/puppetlabs-packer]: https://github.com/puppetlabs/puppetlabs-packer
[vagrant]: https://www.vagrantup.com
