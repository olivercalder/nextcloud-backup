# nextcloud-backup
Backup data from nextcloud

## Installation

Clone this repository somewhere on the machine which hosts the nextcloud server.
Then edit the crontab for `root`:

```sh
sudo crontab -u root -e
```

With `REPO_PATH` as the path to this repository, append the following line:

```
0 4 * * * /usr/bin/sh ${REPO_PATH}/backup-nextcloud.sh
```

This sets daily backups to occur at 4am.

For good measure, you might as well run the script manually yourself, to make sure all required programs and directories are as they should be.
