#!/bin/bash

if [ ! -d /media/sf_utils ]; then
  echo Could not find shared folder mount.  Are you running this script on the host machine? It should be run on the VM.
  exit 1
fi

echo Backing up portal...
su postgres -c 'pg_dump --data-only portal | gzip > /media/sf_utils/portal.sql.gz'
echo Done.
echo Backing up vidispine...
su postgres -c 'pg_dump --data-only vidispine | gzip > /media/sf_utils/vidispine.sql.gz'
echo Done.
