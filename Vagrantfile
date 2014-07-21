# -*- mode: ruby -*-
# vi: set ft=ruby :

$script = <<EOF
sudo apt-get update -y
sudo apt-get install -y git curl htop php5-cli
curl -sL http://get.docker.io | bash
sudo usermod -aG docker vagrant
curl -sL http://getcomposer.org/installer | php
sudo mv composer.phar /usr/local/bin/composer
sudo -i -u vagrant
git clone https://github.com/symfony/symfony.git /vagrant/symfony
cd /vagrant/symfony && composer install
EOF

Vagrant.configure(2) do |config|
  config.vm.box = "ubermuda/debian"
  config.vm.synced_folder '.', '/vagrant'
  config.vm.provision :shell, :inline => $script

  config.vm.provider 'vmware_fusion' do |v|
      v.vmx['memsize'] = 2048
      v.vmx['numvcpus'] = 1
  end
end
