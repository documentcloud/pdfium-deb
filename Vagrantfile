VAGRANTFILE_API_VERSION = "2"
Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box = "ubuntu/trusty64"
  config.vm.provision "shell", inline: <<-SHELL
    sudo apt-get -y update
    sudo apt-get -y install build-essential dpkg-dev dh-make dput ninja gyp libfreeimage-dev libfreetype6-dev valgrind
  SHELL
  config.vm.synced_folder "/Users/ted", "/home/vagrant/ted"
end