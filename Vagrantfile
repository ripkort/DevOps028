Vagrant.configure("2") do |config|

  config.vm.box = "ubuntu/xenial64"

  config.vm.network :forwarded_port, guest: 5432, host: 5432, auto_correct:true
  config.vm.network :forwarded_port, guest: 9000, host: 9000, auto_correct:true

  config.vm.provider "virtualbox" do |vb|
    vb.name = "Samsara"
    vb.memory = "4096"
    vb.cpus = "2"
  end

  config.vm.provision :shell, path: "provision_script.sh"

end
