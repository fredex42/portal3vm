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
  config.vm.define "pluto" do |pluto|
    pluto.vm.box = "s3://gnm-multimedia-archivedtech/portal/Portal_340.box"
    pluto.vm.network "private_network", ip: "169.254.1.20"
    pluto.vm.network "forwarded_port", guest: 8000, host: 8000
    pluto.vm.network "forwarded_port", guest: 8008, host: 8008
    pluto.vm.network "forwarded_port", guest: 8080, host: 8089
    pluto.vm.network "forwarded_port", guest: 5555, host: 5555

    pluto.vm.synced_folder "work", "/media/sf_work"
    pluto.vm.synced_folder "utils", "/media/sf_utils"
    pluto.vm.synced_folder "media/Assets", "/media/sf_Assets"
    pluto.vm.synced_folder "media/Master Outputs", "/media/sf_MasterOutputs"
    pluto.vm.synced_folder "media/Scratch", "/media/sf_Scratch"

    pluto.vm.provider "virtualbox" do |vb|
      # Display the VirtualBox GUI when booting the machine
      vb.gui = false
      #maybe need to do this later, otherwise the ethernet interface does not come up. if you can't log in, comment this out then restart vm
      vb.customize ["modifyvm",:id,"--macaddress1","080027b66c3a"]
      # Customize the amount of memory on the VM:
      vb.memory = "8192"
      vb.cpus = 4
    end

    pluto.vm.provision "file", source: "modify_config.pl", destination: "/tmp/modify_config.pl"
    pluto.vm.provision "file", source: "nginx_8000.pp", destination: "/tmp/nginx_8000.pp"
    pluto.vm.provision "file", source: "pluto/sudo-assetfolder", destination: "/tmp/sudo-assetfolder"
    pluto.vm.provision "shell", inline: <<-SHELL
yum clean expire-cache
yum -y install policycoreutils-python vim swig openssl-devel libxml2-dev libxslt-dev

semodule -i /tmp/nginx_8000.pp
#ensure that rabbitmq is set up properly
rabbitmqctl add_user portal p0rtal
rabbitmqctl add_vhost portal
rabbitmqctl set_permissions -p portal portal ".*" ".*" ".*"

sudo mv /tmp/modify_config.pl /usr/local/bin/modify_config.pl
sudo chmod a+x /usr/local/bin/modify_config.pl
mv /etc/nginx/conf.d/portal.conf /etc/nginx/conf.d/portal.conf.old

sudo mv /tmp/sudo-assetfolder /etc/sudoers.d/assetfolder
echo >> /etc/sudoers.d/assetfolder #ensure that there is a trailing newline or sudo gets upset
sudo chown root.root /etc/sudoers.d/assetfolder
sudo chmod 444 /etc/sudoers.d/assetfolder

perl /usr/local/bin/modify_config.pl --filename /etc/nginx/conf.d/portal.conf.old --position 6 --text 'listen 8000;' --output /etc/nginx/conf.d/portal.conf.2
cat /etc/nginx/conf.d/portal.conf.2 | sed 's.X-Forwarded-Host $host;.X-Forwarded-Host $host:8000;.' > /etc/nginx/conf.d/portal.conf
rm -f /etc/nginx/conf.d/portal.conf.2

sudo systemctl restart nginx

#this must exist, or you get 500 errors in some project management stuff
mkdir -p "/srv/projectfiles/ProjectTemplatesDevEnvironment/"

/opt/cantemo/python/bin/pip install django_debug_toolbar==1.3
for d in `find /media/sf_work/portal-plugins-private/ -maxdepth 1 -type d -iname gnm*`; do
  if [ -h "/opt/cantemo/portal/portal/plugins/`basename ${d}`" ]; then
    rm "/opt/cantemo/portal/portal/plugins/`basename ${d}`"
  fi
  ln -s "$d" "/opt/cantemo/portal/portal/plugins"
done

for d in `find /media/sf_work/portal-plugins-public/portal/plugins -maxdepth 1 -type d -iname gnm*`; do
  if [ -h "/opt/cantemo/portal/portal/plugins/`basename ${d}`" ]; then
    rm "/opt/cantemo/portal/portal/plugins/`basename ${d}`"
  fi
  ln -s "$d" "/opt/cantemo/portal/portal/plugins"
done

cd /media/sf_work/gnmvidispine
/opt/cantemo/python/bin/python setup.py install

cd /media/sf_work/pluto
env SWIG_FEATURES="-cpperraswarn -includeall -I/usr/include/openssl" pip install --upgrade M2Crypto
chmod a+x /media/sf_work/pluto/bin/inve.sh
/media/sf_work/pluto/bin/inve.sh /media/sf_work/pluto/bin/engage_TENTACLE.sh
    echo COMPRESS_ENABLED=False >> /opt/cantemo/portal/portal/settings.py

    systemctl restart portal.target
sudo usermod -a -G vboxsf www-data
sudo bash -c "echo 169.254.1.21 projectlocker >> /etc/hosts"
SHELL
    end #config.vm.define "pluto"

  config.vm.define "projectlocker" do |projectlocker|
    projectlocker.vm.box = "s3://gnm-multimedia-archivedtech/projectlocker/projectlocker-base.box"

    projectlocker.vm.provider "virtualbox" do |vb|
      # Display the VirtualBox GUI when booting the machine
      vb.gui = false
      # Customize the amount of memory on the VM:
      vb.memory = "512"
      vb.cpus = 1
    end

    projectlocker.vm.boot_timeout = 300
    projectlocker.vm.synced_folder "media/ProjectFiles", "/media/sf_ProjectFiles"
    projectlocker.vm.synced_folder "media/ProjectTemplates", "/media/sf_ProjectTemplates"
    projectlocker.vm.synced_folder "media/Assets", "/media/sf_Assets"
    projectlocker.vm.network "private_network", ip: "169.254.1.21"
    projectlocker.vm.network "forwarded_port", guest: 9000, host: 8001
    projectlocker.vm.provision "shell", inline: <<-SHELL
sudo bash -c "echo 169.254.1.20 pluto >> /etc/hosts"
sudo bash -c "echo 169.254.1.21 projectlocker >> /etc/hosts"

sudo -u postgres /usr/pgsql-9.2/bin/createuser projectlocker
sudo -u postgres /usr/pgsql-9.2/bin/createdb projectlocker -O projectlocker

sudo useradd projectlocker
sudo mkdir -p /run/projectlocker
sudo chown projectlocker /run/projectlocker

#firewall rules are set up with firewalld in the packer build

sudo rpm -Uvh https://s3-eu-west-1.amazonaws.com/gnm-multimedia-deployables/projectlocker/717/projectlocker-1.0-717.noarch.rpm
sudo cp /vagrant/projectlocker/defaults /etc/default/projectlocker
sudo cp /vagrant/projectlocker/application.conf /usr/share/projectlocker/conf/application.conf
sudo cp /vagrant/projectlocker/projectlocker.service /usr/lib/systemd/system/projectlocker.service
sudo cp /vagrant/projectlocker/postrun_settings.py /usr/share/projectlocker/postrun
sudo cp /vagrant/projectlocker/logback.xml /usr/share/projectlocker/conf/logback.xml

sudo systemctl daemon-reload
sudo systemctl enable projectlocker
sudo systemctl start projectlocker
sleep 30 #wait for projectlocker service to start up, which will initialise the database tables for us so the sql below works
sudo -u postgres /usr/pgsql-9.2/bin/psql projectlocker << SQL
insert into "StorageEntry" (s_root_path, s_storage_type) VALUES ('/media/sf_ProjectTemplates','Local');
insert into "StorageEntry" (s_root_path, s_storage_type) VALUES ('/media/sf_ProjectFiles','Local');
insert into "ProjectType" (s_name,s_opens_with,s_target_version,s_file_extension) VALUES ('Premiere','Adobe Premiere Pro CC 2017.app', '11.0.2', '.prproj');
INSERT INTO "FileEntry" (id, S_FILEPATH, K_STORAGE_ID, S_USER, I_VERSION, T_CTIME, T_MTIME, T_ATIME, B_HAS_CONTENT) VALUES (1, 'premiere_template.prproj', 1, 'noldap', 1, '2017-01-17 16:55:00.123', '2017-01-17 16:55:00.123', '2017-01-17 16:55:00.123', true);
INSERT INTO "ProjectTemplate" (id, S_NAME, K_PROJECT_TYPE, K_FILE_REF) VALUES (1, 'Premiere test template 1', 1,1);
SELECT pg_catalog.setval('"StorageEntry_id_seq"', 3, true);
SELECT pg_catalog.setval('"ProjectType_id_seq"', 2, true);
SELECT pg_catalog.setval('"FileEntry_id_seq"', 2, true);
SELECT pg_catalog.setval('"ProjectTemplate_id_seq"', 2, true);

SQL
SHELL
  end
end
