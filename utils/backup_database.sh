#!/bin/bash

if [ ! -d /media/sf_utils ]; then
  echo Could not find shared folder mount.  Are you running this script on the host machine? It should be run on the VM.
  exit 1
fi

echo Backing up portal...
su postgres -c 'pg_dump portal | gzip > /tmp/portal.sql.gz'
mv /tmp/portal.sql.gz /media/sf_utils
echo Done.
echo Backing up vidispine...
su postgres -c 'pg_dump vidispine | gzip > /tmp/vidispine.sql.gz'
mv /tmp/vidispine.sql.gz /media/sf_utils
echo Done.
