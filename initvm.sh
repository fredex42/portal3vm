#!/bin/bash

#from http://stackoverflow.com/questions/3915040/bash-fish-command-to-print-absolute-path-to-a-file
function abspath() {
    # generate absolute path from relative path
    # $1     : relative filename
    # return : absolute path
    if [ -d "$1" ]; then
        # dir
        (cd "$1"; pwd)
    elif [ -f "$1" ]; then
        # file
        if [[ $1 == */* ]]; then
            echo "$(cd "${1%/*}"; pwd)/${1##*/}"
        else
            echo "$(pwd)/$1"
        fi
    fi
}

BASEPATH=$(abspath "${BASH_SOURCE%/*}")

echo ------------------------------
echo Checking system...
echo ------------------------------
GITEXE=`which git`
if [ ${GITEXE} == "" ] -or [! -x "${GITEXE}"]; then
  echo You do not appear to have git installed. This is necessary to checkout source code.
  echo Please install git for your platform and then re-run.
  exit 1
fi
VAGRANTEXE=`which vagrant`
if [ ${VAGRANTEXE} == "" ] -or [! -x "${VAGRANTEXE}"]; then
  echo You do not appear to have Vagrant installed. This is necessary to set up the VM.
  echo Please visit https://vagrantup.com and install it for your platform.
  exit 1
fi

echo ------------------------------
echo Setting up environment in ${BASEPATH}...
echo ------------------------------

mkdir -p ${BASEPATH}/work

echo ------------------------------
echo Checking out source code...
echo ------------------------------

mkdir -p ${BASEPATH}/work/pluto
git clone https://github.com/guardian/pluto ${BASEPATH}/work/pluto

if [ "$?" != "0" ]; then
  echo Unable to checkout Pluto source code.  Please contact multimediatech@theguardian.com to request access.
  exit 2
fi

mkdir -p ${BASEPATH}/work/portal-plugins-public
git clone https://github.com/guardian/portal-plugins-public ${BASEPATH}/work/portal-plugins-public

mkdir -p ${BASEPATH}/work/portal-plugins-public
git clone https://github.com/fredex42/portal-plugins-private ${BASEPATH}/work/portal-plugins-private

if [ "$?" != "0" ]; then
  echo Unable to checkout guardian plugins.  Please contact multimediatech@theguardian.com to request access.
  echo "Setup will continue but you won't have all of the plugins installed."
fi

echo ------------------------------
echo Setting up VM...
echo ------------------------------
cd ${BASEPATH}
vagrant up

if [ "$?" != "0" ]; then
  echo Vagrant returned exit code $?.
  echo Something went wrong setting up the VM.  Please consult the Vagrant errors above and fix.
  exit 3
fi

echo ------------------------------
echo Setup completed
echo ------------------------------

echo You can run 'vagrant up' to start the VM and 'vagrant halt' to suspend it.
echo Run 'vagrant destroy' to completely delete it.
