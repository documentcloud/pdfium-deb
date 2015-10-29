VAGRANTFILE_API_VERSION = "2"
Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box = "ubuntu/trusty64"
  
  config.vm.synced_folder '.', "/home/vagrant/pdfium-deb"

  repo_commands = []

  if File.exists? (pdfium_dir = "../pdfium")
    config.vm.synced_folder pdfium_dir, "/home/vagrant/pdfium"
  else
    repo_commands.push "git clone https://pdfium.googlesource.com/pdfium"
  end

  if File.exists? (pdfshaver_dir = "../pdfshaver")
    config.vm.synced_folder pdfshaver_dir, "/home/vagrant/pdfshaver"
  else
    repo_commands.push "git clone https://pdfium.googlesource.com/pdfium"
  end

  config.vm.provision "shell", inline: <<-SHELL
    sudo apt-get -y update
    sudo apt-get -y install build-essential dpkg-dev dh-make dput ninja gyp \
                            libfreeimage-dev libfreetype6-dev valgrind git python-pip
    sudo pip install --upgrade pip

    git clone https://chromium.googlesource.com/chromium/tools/depot_tools.git
    echo 'export PATH=`pwd`/depot_tools:"$PATH"' | tee -a .bashrc
    #{ repo_commands.join("\n") }
    gclient config --unmanaged https://pdfium.googlesource.com/pdfium.git
    gclient sync
  SHELL
  
end