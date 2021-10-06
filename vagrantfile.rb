# -*- mode: ruby -*-
# vi: set ft=ruby :

require 'yaml'

root_path = File.dirname(File.expand_path(__FILE__))
config_file = "#{root_path}/config.yaml"
default_config_file = "#{root_path}/config-dist.yaml"
certs_path =  "#{root_path}/certs"

# initial config
if not File.file?(config_file)
    if File.file?(default_config_file)
        print "Load default config\n"
        FileUtils.cp(default_config_file, config_file)
    else
        raise "The default config file #{default_config_file} is missing!"
    end
end

# load the local config
local_config = YAML.load_file(config_file)
machine = local_config["machine"]
if machine.nil? or machine.empty?
    raise "The machine config is missing!"
end

# Cross-platform way of finding an executable in the $PATH.
def which(cmd)
    exts = ENV['PATHEXT'] ? ENV['PATHEXT'].split(';') : ['']
    ENV['PATH'].split(File::PATH_SEPARATOR).each do |path|
        exts.each do |ext|
            exe = File.join(path, "#{cmd}#{ext}")
            return exe if File.executable?(exe) && !File.directory?(exe)
        end
    end
    nil
end

# install certificates using https://github.com/FiloSottile/mkcert
Dir.mkdir(certs_path) unless File.directory?(certs_path)
if which('mkcert')
    Array(local_config["hosts"]).each do |domain, path|
        cert = "#{certs_path}/#{domain}"
        if !File.file?("#{cert}.key")
            `mkcert -key-file #{cert}.key -cert-file #{cert}.crt #{domain} *.#{domain}`
        end
    end
end

# configure Vagrant
Vagrant.configure("2") do |config|
    # All Vagrant configuration is done here. The most common configuration
    # options are documented and commented below. For a complete reference,
    # please see the online documentation at vagrantup.com.

    # Define list of plugins to install for the local project.
    # Vagrant will require these plugins be installed and available for the project.
    # If the plugins are not available, it will attempt to automatically install them into the local project.
    config.vagrant.plugins = [
        "vagrant-disksize"
    ]

    # Provider-specific configuration so you can fine-tune various
    # backing providers for Vagrant. These expose provider-specific options.
    #
    # View the documentation for the provider you're using for more
    # information on available options.
    case machine["provider"]
        when "virtualbox"
            config.vagrant.plugins.push("vagrant-vbguest")
            config.vbguest.auto_update = machine["guest_tools"]

            mount_options_vagrant = ['dmode=777','fmode=775']
            mount_options = ['dmode=777','fmode=777']

            config.vm.provider :virtualbox do |vb|
                vb.name = machine["name"]
                vb.customize ["modifyvm", :id, "--memory", machine["memory"]]
                vb.customize ["modifyvm", :id, "--cpus", machine["cpu"]]
            end

        when "parallels"
            config.vagrant.plugins.push("vagrant-parallels")

            mount_options_vagrant = ["share"]
            mount_options = ["share"]

            config.vm.provider :parallels do |prl|
                prl.name = machine["name"]
                prl.memory = machine["memory"]
                prl.cpus = machine["cpu"]
                prl.update_guest_tools = machine["guest_tools"]
            end

        else
            raise "Unsupported VM provider #{machine["provider"]}"
    end

    # This sets the username that Vagrant will SSH as by default. Providers
    # are free to override this if they detect a more appropriate user. By
    # default this is "vagrant", since that is what most public boxes are
    # made as.
    if machine["user"]
        config.ssh.username = machine["user"]
    end

    # Every Vagrant virtual environment requires a box to build off of.
    config.vm.box = machine["box"]

    # Requires vagrant plugin install vagrant-disksize`
    config.disksize.size = machine["disk"]

    # Create a forwarded port mapping which allows access to a specific port
    # within the machine from a port on the host machine. In the example below,
    # accessing "localhost:8080" will access port 80 on the guest machine.
    # config.vm.network :forwarded_port, guest: 80, host: 8080

    # Create a private network, which allows host-only access to the machine
    # using a specific IP.
    # !!!!! CHANGE THE IP ADDRESS FOR EACH PROJECT !!!!!
    if machine["ip"]
        Array(machine["ip"]).each do |ip|
            config.vm.network :private_network, ip: ip
        end
    end

    # Create a public network, which generally matched to bridged network.
    # Bridged networks make the machine appear as another physical device on
    # your network.
    if machine["public"]
        config.vm.network :public_network
    end

    # Share an additional folder to the guest VM. The first argument is
    # the path on the host to the actual folder. The second argument is
    # the path on the guest to mount the folder. And the optional third
    # argument is a set of non-required options.
    # Set share folder permissions to 777 so that apache can write files
    config.vm.synced_folder root_path, "/vagrant", :mount_options => mount_options_vagrant
    config.vm.synced_folder certs_path, "/var/ssl/certs", :mount_options => mount_options_vagrant, group: 'root', owner: 'root'
    if local_config["folders"]
        Array(local_config["folders"]).each do |guest, host|
            config.vm.synced_folder host, guest, mount_options: mount_options, group: 'www-data', owner: 'www-data'
        end
    end

    # Enable provisioning with chef solo, specifying a cookbooks path, roles
    # path, and data_bags path (all relative to this Vagrantfile), and adding
    # some recipes and/or roles.
    config.vm.provision :chef_solo do |chef|
        chef.cookbooks_path = "cookbooks"

        if local_config["cookbooks"]
            Array(local_config["cookbooks"]).each do |cookbook|
                chef.add_recipe cookbook
            end
        end

        chef.json = local_config

        chef.arguments = "--chef-license accept"
    end

    # Ensures the Apache service is properly started once all is settled
    config.vm.provision "shell", inline: "service apache2 restart", run: "always"
end
