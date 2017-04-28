# -*- mode: ruby -*-
# vi: set ft=ruby :

## https://github.com/WhoopInc/vagrant-s3auth
unless Vagrant.has_plugin?('vagrant-s3auth')
  # Attempt to install ourself. Bail out on failure so we don't get stuck in an
  # infinite loop.
  system('vagrant plugin install vagrant-s3auth') || exit!

  # Relaunch Vagrant so the plugin is detected. Exit with the same status code.
  exit system('vagrant', *ARGV)
end

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
Vagrant.configure("2") do |config|
  config.vm.box = "https://s3-eu-west-1.amazonaws.com/gnm-multimedia-archivedtech/portal/Portal_311v2.box"

  config.vm.network "forwarded_port", guest: 8000, host: 8000
  config.vm.network "forwarded_port", guest: 8008, host: 8008
  config.vm.network "forwarded_port", guest: 8080, host: 8080
  config.vm.network "forwarded_port", guest: 5555, host: 5555

  config.vm.synced_folder "work", "/media/sf_work"
  config.vm.synced_folder "utils", "/media/sf_utils"
  
  config.vm.provider "virtualbox" do |vb|
    # Display the VirtualBox GUI when booting the machine
    vb.gui = false

    vb.customize ["modifyvm",:id,"--macaddress1","080027b66c3a"]
    # Customize the amount of memory on the VM:
    vb.memory = "8192"
    vb.cpus = 4
  end

  config.vm.provision "file", source: "modify_config.pl", destination: "/tmp/modify_config.pl"
  config.vm.provision "file", source: "nginx_8000.pp", destination: "/tmp/nginx_8000.pp"
  config.vm.provision "shell", inline: <<-SHELL
yum clean expire-cache
yum -y install policycoreutils-python

semodule -i /tmp/nginx_8000.pp
#ensure that rabbitmq is set up properly
rabbitmqctl add_user portal p0rtal
rabbitmqctl add_vhost portal
rabbitmqctl set_permissions -p portal portal ".*" ".*" ".*"

sudo mv /tmp/modify_config.pl /usr/local/bin/modify_config.pl
sudo chmod a+x /usr/local/bin/modify_config.pl
mv /etc/nginx/conf.d/portal.conf /etc/nginx/conf.d/portal.conf.old

perl /usr/local/bin/modify_config.pl --filename /etc/nginx/conf.d/portal.conf.old --position 6 --text 'listen 8000;' --output /etc/nginx/conf.d/portal.conf.2
cat /etc/nginx/conf.d/portal.conf.2 | sed 's.X-Forwarded-Host $host;.X-Forwarded-Host $host:8000;.' > /etc/nginx/conf.d/portal.conf
rm -f /etc/nginx/conf.d/portal.conf.2

sudo systemctl restart nginx

/opt/cantemo/python/bin/pip install django_debug_toolbar==1.3
for d in `find /media/sf_work/portal-plugins-private/ -type d -iname gnm*`; do
  if [ -h "/opt/cantemo/portal/portal/plugins/`basename ${d}`" ]; then
    rm "/opt/cantemo/portal/portal/plugins/`basename ${d}`"
  fi
  ln -s "$d" "/opt/cantemo/portal/portal/plugins"
done

for d in `find /media/sf_work/portal-plugins-public/ -type d -iname gnm*`; do
  if [ -h "/opt/cantemo/portal/portal/plugins/`basename ${d}`" ]; then
    rm "/opt/cantemo/portal/portal/plugins/`basename ${d}`"
  fi
  ln -s "$d" "/opt/cantemo/portal/portal/plugins"
done

cd /media/sf_work/gnmvidispine
/opt/cantemo/python/bin/python setup.py install

cd /media/sf_work/pluto
/media/sf_work/pluto/bin/inve.sh /media/sf_work/pluto/bin/engage_TENTACLE.sh
    echo COMPRESS_ENABLED=False >> /opt/cantemo/portal/portal/settings.py

    systemctl restart portal.target
  SHELL

end
