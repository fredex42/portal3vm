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

Accessing the environment
----

You can access the environment at: http://localhost:8000/.

Sometimes the redirects can get screwed up, leading to "page not found" errors when logging in.  Simply put the :8000 port specifier back into the URL to fix this.

Hibernating
----

Simply run vagrant halt from the commandline in the checkout directory to shut down the VM, and vagrant up to restart it.
