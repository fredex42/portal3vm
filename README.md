# portal3vm
Setup for pluto et. al. on Portal 3

This repo contains a convenience script to get up and running on Pluto development with Portal 3 quickly.

Requirements
----

- Vagrant - https://www.vagrantup.com/
- Virtualbox 5.x - https://www.virtualbox.org/wiki/Downloads
- git
- access to the Pluto and portal-plugins-* repositories

How to use
----

- check out this repo into a new directory
- run ./initvm.sh

This will:

- make a "work" directory
- check out the repos into this directory
- download a licensed development environment as a Vagrant box
- install it into Virtualbox
- perform development setup ("engage_TENTACLE") on the plugins

Backing up your database
----

This VM contains its own postgres installation with its own database.  When you
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

Overwriting your database from backup
----

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

Accessing the environment
----

You can access the environment at: http://localhost:8000/.

Sometimes the redirects can get screwed up, leading to "page not found" errors when logging in.  Simply put the :8000 port specifier back into the URL to fix this.

Hibernating
----

Simply run vagrant halt from the commandline in the checkout directory to shut down the VM, and vagrant up to restart it.

Rebuilding the base box
----

If you need to update the version of CentOS, Portal or you just have a different version of VirtualBox, you may need to rebuild the base box.  This can be done using
the data under the ```packer``` subdirectory, consult the README there for more information.
