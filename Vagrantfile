# -*- mode: ruby -*-
# vi: set ft=ruby :

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
Vagrant.configure("2") do |config|
  config.vm.box = "https://s3-eu-west-1.amazonaws.com/gnm-multimedia-archivedtech/portal/Portal31.box"
  config.vm.network "forwarded_port", guest: 8000, host: 8000
  config.vm.network "forwarded_port", guest: 8080, host: 8080
  config.vm.network "forwarded_port", guest: 5555, host: 5555

  config.vm.synced_folder "work", "/media/sf_work"

  config.vm.provider "virtualbox" do |vb|
    # Display the VirtualBox GUI when booting the machine
    vb.gui = false

    # Customize the amount of memory on the VM:
    vb.memory = "8192"
    vb.cpus = 4
  end

  config.vm.provision "file", source: "modify_config.pl", destination: "/tmp/modify_config.pl"

  config.vm.provision "shell", inline: <<-SHELL
yum clean expire-cache
#uncomment this line if you need to debug selinux problems
#yum -y install policycoreutils-python

sudo mv /tmp/modify_config.pl /usr/local/bin/modify_config.pl
sudo chmod a+x /usr/local/bin/modify_config.pl
mv /etc/nginx/conf.d/portal.conf /etc/nginx/conf.d/portal.conf.old

perl /usr/local/bin/modify_config.pl --filename /etc/nginx/conf.d/portal.conf.old --position 6 --text 'listen 8000;' --output /etc/nginx/conf.d/portal.conf
setenforce permissive #otherwise selinux won't let nginx bind to port 8000
systemctl restart nginx

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

cd /media/sf_work/pluto
/media/sf_work/pluto/bin/inve.sh /media/sf_work/pluto/bin/engage_TENTACLE.sh
    echo COMPRESS_ENABLED=False >> /opt/cantemo/portal/portal/settings.py
    
    service portal-celery-indexer restart
    service portal-celery-main restart
    service portal-celery-notifyindexer restart
    service portal-celery-re3 restart
    service portal-celerybeat restart
    service portal-cleanup restart
    service portal-notifier restart
    service portal-web restart
  SHELL

end
