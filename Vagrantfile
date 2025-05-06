Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/focal64"

  # On change les ports host pour éviter les conflits
  config.vm.network "forwarded_port", guest: 8080, host: 18080  # Jenkins
  config.vm.network "forwarded_port", guest: 9000, host: 19000  # SonarQube
  config.vm.network "forwarded_port", guest: 8000, host: 18000  # Autre app

  config.vm.provider "virtualbox" do |vb|
    vb.name = "devops-vm"
    vb.memory = 4096
    vb.cpus = 2
  end

  config.vm.hostname = "devops"
end

