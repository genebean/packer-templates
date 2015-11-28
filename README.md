# genebean-packer-templates

Packer templates for building base VM boxes.
The ideas for this have been pulled from two sources:
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
$ cd some-distribution-folder
```

### Build all boxes

```bash
$ ./build-all.sh
```

This will build the following boxes:
- nocm: one with no configuration management installed
- puppet: one with Puppet 3.x installed
- puppet-agent: one with Puppet 4.x installed
- rvm-193: one with RVM and version 1.9.3 of Ruby installed
- rvm-221: one with RVM and version 2.2.1 of Ruby installed

### Build one box at a time

```bash
$ packer build template-base.json
# Replace template-some-type with the type of box you want to build.
$ packer build template-some-type.json
```

### Build for single platform

```bash
# for Virtualbox:
$ packer build -only=virtualbox-base template-base.json
$ packer build -only=virtualbox-vagrant-some-type template-some-type.json

# for VMware:
$ packer build -only=vmware-base template-base.json
$ packer build -only=vmware-vagrant-some-type template-some-type.json
```


### Parallel builds can be run when using Packer 0.6.0 or later.

```bash
$ packer build -parallel=true template.json
```

### Supported versions

This templates was tested using a packer 0.8.6


[shiguredo/packer-templates]: https://github.com/shiguredo/packer-templates
[puppetlabs/puppetlabs-packer]: https://github.com/puppetlabs/puppetlabs-packer
