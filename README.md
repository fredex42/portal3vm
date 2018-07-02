# portal3vm
Setup for pluto et. al. on Portal 3

This repo contains a convenience script to get up and running on Pluto development with Portal 3 quickly.

## Requirements

- Vagrant - https://www.vagrantup.com/
- Virtualbox 5.x - https://www.virtualbox.org/wiki/Downloads
- git
- access to the Pluto and portal-plugins-* repositories
- access to GNM Multimedia S3

## How to use

- check out this repo into a new directory
- ensure that you have GNM Multimedia AWS credentials in your environment.
Normally, this is done by logging into Janus, going to the Multimedia account
and selecting 'Credentials' then 'Copy'.  Paste the resulting text into a terminal, then set the `AWS_PROFILE` environment variable to `multimedia` before running initvm.sh
- If you do not have access to Janus, contact `Multimediatech@theguardian.com` to request access
- run ./initvm.sh

This will:

- make a "work" directory
- check out the repos into this directory
- download a licensed development environment as a Vagrant box
- install it into Virtualbox
- perform development setup ("engage_TENTACLE") on the plugins
- download and set up a second environment for projectlocker
- connect Projectlocker and Portal via a private host-only network with static IPs

## Updating your license

The license that the base box is built with may well be out of date when you install.  In this case you'll need to get a new license and install it.  You could rebuild the whole base box with the scripts in `packer/` but there is an easier way...
- copy your new license to the same directory that this file is in
- connect to the portal environmant: `$ vagrant ssh pluto`
- once you're in the Portal VM, shut down Portal and Vidispine: `$ sudo systemctl stop portal.target && sudo systemctl stop vidispine.service`
- copy the file where Portal needs it: `$ sudo cp /vagrant/{your-license-filename} /etc/cantemo/portal/key`
- copy the file where Vidispine needs it: `$ sudo cp /vagrant/{your-license-filename} /etc/vidispine/License.lic`
- **IMPORTANT** - Vidispine can't parse the license file in the state that you are passed it. You need to open `/etc/vidispine/License.lic` in a text editor like `vim` and **delete** everything from the top down to, and including, the line that reads `[vidispine]`
- now start the services up again: `$ sudo service vidispine start`, wait 30-60 seconds, `$ sudo systemctl start portal.target`
- your license should be updated.  If it fails to parse, consult the Portal and/or Vidispine logs to find out what the problem is.

# Configuring Your environment

Once the VMs are up and running, you will need to do some configuration.

## Pluto

### Initial configuration

- Log into Portal (aka Pluto) at http://localhost:8000 using the default 'admin' credential.
- If the box tells you that the license is out of date, then follow the instructions for `Updating your License`, above
- If you get a `500 Server Error`, then check that the migrations have applied properly: `sudo /opt/cantemo/portal/manage.py migrate`.  Restart Portal once this has completed successfully
- This should prompt you to accept the license agreement, and then ask to make some configuration of Vidispine.  Simply click Next and wait a while.
- If all is good, then it should eventually report that Vidispine has been configured.  Clicking Next will take you to a default search page.

### Create a user for projectlocker

- Projectlocker needs a service account in order to communicate with Pluto.
- In `Admin`, go to `Users and Groups` then `Add User`
- By default, Projectlocker on this VM is configured with the username `projectlocker_svc` and the password `projectlocker`. Create this user and assign it to the `admin` group.
- Projectlocker uses this account to perform regular scans of commissions, project types etc so it's best to do this first to give it time to sync up.

### Set up Storages

- Go to the Admin panel by clicking Admin in the menus list, and then select Storages
- Remote the existing `media1` storage
- Set up a storage called `Assets` and point it at `/media/sf_Assets`. This links it to the Virtualbox shared folder which is mounted from media/Assets under your checkout in the host filesystem.
- Set up a storage called `Scratch` and point it at `/media/sf_Scratch`
- **Make sure that you create them in this order.** The default Pluto dev settings has `VX-2` as the Assets storage, this is needed to make the `Recreate Asset Folder` option work.
- Go to NLE Setup, also in the admin page/menu.  Under the `Assets` storage, enter the path that the shared folder can be found in the host filesystem.
- Go to System Settings, and under `Default upload storage` select your `Scratch` storage.

### Set up group access

- Go to `All Groups` and select the `admin` group.
- Go to the `Metadata Groups` tab and ensure that `admin` has access to all metadata Groups
- Also set the all three `default metadata group` options to `Asset`

### Set up Pluto global metadata

- Pluto needs some things such as commissioners, projects configured as Vidispine global metadata.
- In order to set these up, go to `Manage` -> `Metadata Elements`. If you don't see the items listed below, follow the steps under `Set up group access` again.
- Select `Commissioner` and add a fake commissioner and supply the name of the working group that they hypothetically lead, and hit `Submit`.
- Select `Working Group` and add the working group name that you supplied to `Commissioner`.  You don't need default tags.
- Finally, select `ProjectType` and add a project type called `Premiere`.
- This data is cached from Vidispine at startup and therefore won't show in the UI until Portal is restarted.
- To restart, log in to the VM by running `vagrant pluto ssh` and then run `systemctl restart portal.target`
- Verify that your data has been cached by creating a new Commission from the `Home` page. You should see the values you set as options for Commissioner, Working Group and Project Type.  If you continue through and create the commission, neither a project nor asset folder will create yet.


### Set up opt-ins

Currently Projectlocker is officially Beta, so needs to be opted-in on the Pluto side.
- click You are logged in as `admin` at the top-right of the page to go to `admin`'s user profile
- on the left-hand side click `My Opt-Ins`
- click `Add` and then enter the string `projectlocker` in the `Feature` field and hit `Save`

### Set up projectlocker

Projectlocker only authenticates via LDAP/AD, and since there was no point building an LDAP VM as well authentication is disabled in the dev VM. `ldap.ldap_protocol` in `application.conf` is set to `none`, so it behaves as if there is one user in the system called `noldap`.

- Connect to Projectlocker by going to `http://localhost:8001/` in your browser. You should get the Projectlocker welcome screen.
- Projectlocker should already have its base storages (ProjectFiles and ProjectTemplates) configured by the Vagrantfile
- Go to Storages and click the Edit icon next to the ProjectFiles storage.  Click through to `Subfolder Location` and set the `Client mount point` to the location of `media/ProjectFiles` from this checkout in the host filesystem.
- Go to `Next` to see the summary, then `Confirm` your change.
- Click on `Server Defaults` in the main menu
- Make sure that `Default storage for created projects` is set to `/media/sf_ProjectFiles on Local`
- You should see another option called `Project template to use for Pluto 'Premiere':`.  If not, there may be a communication problem between
Portal and Projectlocker.  Try restarting Projectlocker while checking the logfile `/var/log/projectlocker/projectlocker.log`.  Or you may have just followed the instructions so quickly that it has not yet synced up the project types (you need to have restarted Portal as in `Set up Pluto global metadata` before it can "see" the updated values)
- There should be a template called `Premiere test template 1`.  Select this for the the  `Project template to use for Pluto 'Premiere':`; you don't need to confirm or click Save, the value should be saved immediately.

### Set up PlutoHelperAgent

This step is optional, in that it is not needed to make the server-side code work.  But it is necessary to make the client-side integration work as it does in the wild.
PlutoHelperAgent is a Mac desktop app that allows asset folders and project files to be opened from the browser with client-local apps.

- Get a copy of PlutoHelperAgent - contact mailto:multimediatech@theguardian.com.
- Install it by copying to your Applications folder, and double-click to run
- You should see a small icon with the letter P in the notifications tray at the top-right of your Mac screen; it'll be either blue or red, most likely red (indicating that the configuration is not correct)
- Click the icon and go to `Preferences...`
- Set `Server URL` to `http://localhost:8001`, `Username` and `Password` to the default admin login, and `Open Script` to `/usr/bin/open`
- Then hit `Test Connection.` After a second you should get the message `Okay` at the bottom of the window.  Click `Save` and `Close`.

# Operations

## Backing up your database

Each VM contains its own postgres installation with its own database.  When you
boot for the first time, the database will be ready for use but with no data in it;
you must run the Portal installation wizard the first time to get everything set up.

If you want to rebuild or upgrade for any reason, or are just worried about the VM
losing data, you will need to back up the database.  A script is provided to do this.

Simply run (in the VM):

```
$ sudo /media/sf_utils/backup_database.sh
```

This should back up the Portal database to `{portal3vm}/utils/portal.sql.gz`,
and the Vidispine database to `{portal3vm}/utils/vidispine.sql.gz`.

## Overwriting your database from backup

If you have a database backup that you want to put into the dev VM, you can easily
do so but this does involve over-writing the existing database.

These instructions assume that you have put your Portal database backup into
`{portal3vm}/utils/portal.sql.gz` and Vidispine database backup into
`{portal3vm}/utils/vidispine.sql.gz`.
The following commands should be run in the VM:

```
# systemctl stop portal.target
# systemctl stop vidispine
# su postgres -c 'psql'
postgres=# drop database portal;
postgres=# drop database vidispine;
postgres=# \q
# su postgres -c 'createdb vidispine'
# su postgres -c 'createdb portal'
# su postgres -c 'zcat /media/sf_utils/vidispine.sql.gz | psql vidispine'
# su postgres -c 'zcat /media/sf_utils/portal.sql.gz | psql portal'
# systemctl start vidispine
[wait for vidispine to load up fully.....]
# /opt/cantemo/portal/manage.py sync_commissions
# /opt/cantemo/portal/manage.py sync_masters
# systemctl start portal.target
```

Once you have run this, you will need to trigger re-indexes using the Admin interface
in this order:

- Vidispine collections
- Vidispine items
- Vidispine files
- Portal collections
- Portal items
- Portal files

# Accessing the environment

You can access the environment at: http://localhost:8000/.

Sometimes the redirects can get screwed up, leading to "page not found" errors when logging in.  Simply put the :8000 port specifier back into the URL to fix this.

## Hibernating

Simply run vagrant halt from the commandline in the checkout directory to shut down the VM, and vagrant up to restart it.

## Updating the base box

From time to time, the base box is updated to take account of changes to the underlying CentOS installation, Portal and Vidispine.
In order to upgrade to a new base box, simply:

- back up your database as described in `Backing up your database`, above
- exit the old VM and run `vagrant destroy` to delete it
- run `git pull` to download the latest version of portal3vm
- run `vagrant up` to build a new VM from the latest base box
- restore your old database as described in `Overwriting your database from backup`, above

Rebuilding the base box
----

If you need to update the version of CentOS, Portal or you just have a different version of VirtualBox, you may need to rebuild the base box.  This can be done using
the data under the ```packer``` subdirectory, consult the README there for more information.
