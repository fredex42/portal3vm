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
echo -e "\x1B[32mChecking system...\x1B[0m"
echo ------------------------------
GITEXE=`which git`
if [ "${GITEXE}" == "" ] || [ ! -x "${GITEXE}" ]; then
  echo You do not appear to have git installed. This is necessary to checkout source code.
  echo Please install git for your platform and then re-run.
  exit 1
else
  echo Found git at ${GITEXE}
fi

VAGRANTEXE=`which vagrant`
if [ "${VAGRANTEXE}" == "" ] || [ ! -x "${VAGRANTEXE}" ]; then
  echo You do not appear to have Vagrant installed. This is necessary to set up the VM.
  echo Please visit https://vagrantup.com and install it for your platform.
  exit 1
else
  echo Found vagrant at ${VAGRANTEXE}
fi

if [ "${AWS_PROFILE}" == "" ]; then
  echo The AWS_PROFILE environment variable is not set.  While this may not be an issue,
  echo you need to have AWS credentials in order to download the base VM image later on.
  echo I recommend you type CTRL-C here to stop the script and make sure that you have
  echo the right AWS credentials as described in the README document before retrying
  echo
  echo Press CTRL-C to stop or any other key to continue...
  read -n 1 -s
fi

echo ------------------------------
echo -e "\x1B[32mSetting up environment in ${BASEPATH}...\x1B[0m"
echo ------------------------------

mkdir -p ${BASEPATH}/work

echo ------------------------------
echo -e "\x1B[32mChecking out source code...\x1B[0m"
echo ------------------------------

mkdir -p ${BASEPATH}/work/pluto
git clone https://github.com/guardian/pluto ${BASEPATH}/work/pluto

if [ "$?" != "0" ]; then
  echo Unable to checkout Pluto source code.  Please contact multimediatech@theguardian.com to request access.
  exit 2
fi

cd ${BASEPATH}/work/pluto

mkdir -p ${BASEPATH}/work/portal-plugins-public
git clone https://github.com/guardian/portal-plugins-public ${BASEPATH}/work/portal-plugins-public

mkdir -p ${BASEPATH}/work/portal-plugins-public
git clone https://github.com/fredex42/portal-plugins-private ${BASEPATH}/work/portal-plugins-private

mkdir -p ${BASEPATH}/work/gnmvidispine
git clone https://github.com/fredex42/gnmvidispine ${BASEPATH}/work/gnmvidispine

if [ "$?" != "0" ]; then
  echo -e "\x1B[31mERROR\x1B[0m Unable to checkout guardian plugins.  Please contact multimediatech@theguardian.com to request access."
  echo "Setup will continue but you won't have all of the plugins installed."
fi

echo ------------------------------
echo -e "\x1B[32mSetting up VM...\x1B[0m"
echo ------------------------------
cd ${BASEPATH}
mkdir -p media/Assets
mkdir -p "media/Master Outputs"

vagrant up

if [ "$?" != "0" ]; then
  echo "\x1B[31mERROR\x1B[0m Vagrant returned exit code $?."
  echo Something went wrong setting up the VM.  Please consult the Vagrant errors above and fix.
  exit 3
fi

echo ------------------------------
echo -e "\x1B[32mSetup completed\x1B[0m"
echo ------------------------------

echo -e "You should now be able to access Portal by going to \x1B[1mhttp://localhost:8000/\x1B[0m and using default credentials."
echo You can run \'vagrant up\' to start the VM and \'vagrant halt\' to suspend it.
echo Run \'vagrant destroy\' to completely delete it.
