# Overview of genebean/packer-templates

This repo contains my [Packer][packer] templates for building bases boxes used in [Vagrant][vagrant]. By default it will build the Vagrant boxes in Virtualbox. There are also definitions for VMware boxes but these are not as heavily tested due to only having VMware at work. 

- [Usage](#Usage)
  - [Installing Packer](#Installing-Packer)
  - [Running Packer](#Running-Packer)
    - [The box-versions file](#The-box-versions-file)
    - [Build all boxes in all folders](#Build-all-boxes-in-all-folders)
    - [Build all boxes in a single folder](#Build-all-boxes-in-a-single-folder)
    - [Build one box at a time](#Build-one-box-at-a-time)
    - [Build for single platform](#Build-for-single-platform)
    - [Supported Packer version](#Supported-Packer-version)
- [Development](#Development)
  - [Build Scripts](#Build-Scripts)
  - [Templates](#Templates)
  - [Specialty Templates](#Specialty-Templates)
    - [template-pebaseline](#template-pebaseline)
    - [upload-vsphere-*](#upload-vsphere)
- [What's next](#Whats-next)

The files in the repo are laid out so that each OS and version combo has a top-level folder. Each os also has a common folder where shared code lives. Under each OS version folder are the files needed to build that combo in several different configurations including:

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

The base version is a little different than the others. When used for a virtual machine it does not produce a Vagrant box but rather creates a VM that is used by all the other builds.

Many of the ideas and concepts for these templates have been pulled from the following two sources:

- [shiguredo/packer-templates][shiguredo/packer-templates] -
  I originally forked this repo but have since reworked it completely based on
  some tricks learned from my next source.
- [puppetlabs/puppetlabs-packer][puppetlabs/puppetlabs-packer] -
  I now utilize an idea gathered from here to build a base VM and then
  separately build each box, adding in needed modifications as needed as part of
  the build process.

## Usage

### Installing Packer

If you're using Homebrew:

```bash
$ brew tap homebrew/binary
$ brew install packer
```

Otherwise, download the latest packer from http://www.packer.io/downloads.html
and unzip the appropriate directory.

### Running Packer

```bash
$ git clone https://github.com/genebean/packer-templates.git
$ cd packer-templates
```

#### The box-versions file

The build scripts below all reference a file called `box-versions`. This file simply contains the list of templates that each script should loop over so that the list is not duplicated between scripts.

#### Build all boxes in all folders

```bash
$ ./run-all-builds.sh
```

By default, this will build all boxes by looping over the top level folders and calling `build-all.sh` in each. If you want to speed things up a bit you can run all the `build-all.sh` scripts in parallel like this:

```bash
$ ./run-all-builds.sh -p
```

#### Build all boxes in a single folder

```bash
$ cd some-os-version-combo
$ ./build-all.sh
```

#### Build one box at a time

```bash
builder=virtualbox
box_prefix=centos-7 # or centos-6
DIR='../centos-common'
# base must be built before other templates
$ packer build -force -only=${builder}-base-${box_prefix} -var-file=template-base-vars.json $DIR/template-base.json

box=puppet-latest # or any other template you wish to use
$ packer build -force -only=${builder}-vagrant-${box}-${box_prefix} -var-file=template-std-vars.json $DIR/template-${box}.json
```

#### Build for single platform

```bash
# for Virtualbox:
$ ./build.sh vagrant

# for VMware:
$ ./build.sh vmware
```

#### Supported Packer version

These templates were tested using a packer 1.4.1

## Development

If you would like to make new templates or change these to have your name instead of `genebean` then you will want to take note of the variables in the templates and build scripts. Below are some details to get you started.

### Build Scripts

These scripts have just one thing you may want to change:

```bash
# <os-version combo>/scripts/vars.sh:

# This is used in the MOTD
vagrant_user='GeneBean'
```

If you are making a new OS and version combo then you will  want to update the `box_prefix` value in `build.sh` and `build-all.sh` in your new directory.

### Templates

All the templates utilize variables for most things that you might want to change. These variables are located at the top of each templates's JSON file. Each folder non-common folder also contains these files that are passed to Packer:

- `template-base-vars.json`: This contains all the version-specific info used while build the base image via the template in the common folder
- `template-std-vars.json`:  This sets the `os` variable and the `common_scripts` variable for all the boxes that get built off of the base image

### Specialty Templates

These templates are in a slightly different class than the standard ones above: they do specialize things and may well require extra configuration to work. They also are not included in `box-versions` which means they are not part of the `build.sh` or `build-all.sh` scripts.

#### template-pebaseline

This template is designed to work with a Puppet Enterprise installation. During the provisioning phase this template will install a Puppet agent using the `curl|bash` method, prompt you to go sign the cert, run puppet twice, and then prompt you to go purge the node. It will also clean up the machine being built so that it can easily be renamed and joined back to puppet later. The primary purpose of this template is to generate an image that can be uploaded to VMware vCenter and used as a template there. Currently, the cleanup process includes things specific to where I work. None of these should be detrimental to anyone else but you may want to customize these prior to running in your environment.

#### upload-vsphere-*

These specialized templates take the output of the corresponding `template-*`, prep it for upload to vCenter, and then upload it via the vsphere post-processor to a vCenter. To use this template you must first set several environment variables. To make this easier there is a `env-vars.sample` in this repository that you can copy to `env-vars`, fill in as needed, and then source. The file `env-vars` has been added to the .gitignore file so that it will not be tracked by version control.

## What's next

The Ubuntu 14.04 folder currently is just a carry-over from the old setup. I would like to build this one out like the CentOS ones. I'd also like to add in Windows templates and, possibly, support for KVM.

[shiguredo/packer-templates]: https://github.com/shiguredo/packer-templates
[packer]: https://packer.io
[puppetlabs/puppetlabs-packer]: https://github.com/puppetlabs/puppetlabs-packer
[vagrant]: https://www.vagrantup.com
