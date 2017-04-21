#Rebuilding the base box

This subdirectory contains the necessary pieces to rebuild the base box which
contains the Vidispine and Portal stack installation.  You only need to use these
if you have to:

 - update the version of CentOS
 - update the version of Portal
 - have compatibility issues with your version of Virtualbox

Prerequisites
----

- Packer - https://www.packer.io/downloads.html
- Virtualbox - https://www.virtualbox.org/wiki/Downloads
- Plenty of RAM.  The installation creates a VM with 8Gb RAM, and it uses all of it.  I get memory pressure running this on a Macbook Pro with 16Gb RAM.  I would recommend shutting down all other RAM-heavy programs before running this.
- Portal installation files.  Portal is a commercial product and as such is not included here.  You should get hold of the installation tarball from Cantemo or your distributor, and put it into the portal_install directory (don't untar it)
- Portal license.  You should get hold of this from Cantemo or your distributor, and put it into the portal_install directory.  The installation expects the file to be called ```license.key```.

Set Up
----
You should check the filename of your Portal tarball, and update packer-portal.json to reflect it.  Replace every occurrence of ```RedHat7_Portal_3.0.1.tar``` with the name of your tarball, and also update the directory name on line 70 ```RedHat7_Portal_3.0.1``` to the base name of your tarball.

If you need to update CentOS, you should update ```iso_url``` at line 6 of packer-portal.json to point to the ISO image of the minimal installation CD for the version of CentOS you want to use.  Make sure that the version of Portal you are trying to install is compatible with this version of RedHat/CentOS.

Building the image
----

cd to this directory and run:

```
packer build packer-portal.json
```

This will take some time to run.  The ISO image will be downloaded, a new VM created
and the OS will be installed.  It will reboot, and the Guest Additions from your installed version of VirtualBox will be installed. Then, the installation tarball will be decompressed and the installation run.  If your installation or license is incorrect, you will see an error at this point

Using the image
----

When the build process completes, you should be left with a file called ```packer_virtualbox-iso_virtualbox.box```.  Rename this file, and keep it safe.
You can then update Vagrantfile in the parent directory to this to point to this newly built image, and run ```initvm.sh``` as described in the parent README to set up your new dev environment.
