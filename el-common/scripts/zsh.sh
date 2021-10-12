# install git and zsh
yum -y install git zsh

# set the vagrant user's shell
usermod -s /bin/zsh vagrant

# grab a modified .zshrc
curl -sSo /home/vagrant/.zshrc https://raw.githubusercontent.com/genebean/dots/master/link/nix/zshrc

# comment out starting the gpg agent since we are not setting it up
sed -i 's/^gpg-connect-agent/#gpg-connect-agent/' /home/vagrant/.zshrc

# since this isn't a mac we don't need the brew plugin
sed -i "s/brew\sbundler/bundler/" /home/vagrant/.zshrc

# the custom config looks for .private-env so let's make it
touch /home/vagrant/.private-env

# download customized themes
mkdir -p /home/vagrant/repos/customized-oh-my-zsh
git clone --progress --verbose https://github.com/genebean/my-oh-zsh-themes.git /home/vagrant/repos/customized-oh-my-zsh/themes

# install oh-my-zsh
git clone --progress --verbose https://github.com/robbyrussell/oh-my-zsh.git /home/vagrant/.oh-my-zsh

# fix permissions
chown -R vagrant:vagrant /home/vagrant
