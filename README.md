# Bash Backup

I needed a quick and dirty script to backup my servers to a remote host.  This assumes a borg repo has already been created.  The backup that can be run an infinite (depending on storage space, obviously) times.  Borg does do version checked and will only write changes since last write.  Check out Borg's documentation for more info on this.  I plan on moving this to docker and using python when I get more time.

This can easily be wrapped around cron to run on any given interval. 

## Init borg repo

Steps to init the borg repo.

### Setup your ssh key for password-less auth

Create a new ssh key. (Without a passcode)

```
ssh-keygen -b 4096 -f ~/.ssh/borg-test-sshkey
```

Add the key to authorized list. This assumes a remote storage box, but easily could be placed on a server's `~/.ssh/authorized_keys` but you'll have to modify the below commands to point to the correct directory to init the repo.

```
cat ~/.ssh/borg-test-sshkey.pub | ssh -p22 userName@storageProvider install-ssh-key
```

Add your encryption passcode as an environment variable: `BORG_PASSPHRASE` to the user executing the script.

Modify your ssh config file to add the mappings, makes the commmands significantly easier to read.

```
# ~/.ssh/config

Host ssh-borg-backup-test
        Hostname storageProvider
        IdentityFile ~/.ssh/borg-test-sshkey
        User userName
        Port 22
```

SSH into the host and create the directory.  (This will be where your borg backup repo will live)

```
ssh ssh-borg-backup-test

mkdir /path/to/where/you/want/to/store/the/repo

exit
```

### Init the actual repo

We'll use repokey encryption just so the key will live in the repo.  

```
borg init --encryption=repokey ssh-borg-backup-test:/path/to/where/you/want/to/store/the/repo
```

Then we'll want to export the key and store it locally.

```
borg key export ssh-borg-backup-test:/path/to/where/you/want/to/store/the/repo
```

## Manually Running the create

If at this point, you want to ensure that everything was created successfully, (and for some piece of mind) then you can manually run your first (or any) borg create command to manually backup your data. 

You'll need a distinct backup name so I recommend the date. 

```
borg create --progress --stats ssh-borg-backup-test:/path/to/where/you/want/to/store/the/repo::archiveNameInstance_22_11_22_12_00 /directory/that/you/want/to/backup/on/the/host /optionally/second/path
```

### Validation 

You can either list out your data with the archive that you used.

```
borg list ssh-borg-backup-test:/path/to/where/you/want/to/store/the/repo::archiveNameInstance_22_11_22_12_00
```

You can list out the archives at any point to see what is stored in the repo just be excluding the repo name.

```
borg list ssh-borg-backup-test:/path/to/where/you/want/to/store/the/repo
```

You can also run an extract using the specific archive that you used.  You can move std out or just `cd` into your test directory on your host. 

```
borg extract ssh-borg-backup-test:/path/to/where/you/want/to/store/the/repo::archiveNameInstance_22_11_22_12_00
```

## Backing up

```
chmod +x backup.sh
```

Fill in the values:

- `BORG_PASSPHRASE`: Encryption Password
- `BORG_SSH_CONFIG_NAME`: "ssh-borg-backup-test"
- `BORG_REMOTE_DIRECTORY_PATH`: "/path/to/where/you/want/to/store/the/repo"
- `BORG_ARCHIVE_NAME_PREFIX`: "archiveNameInstance" | Will append the date to make it distinct
- `BORG_BACKUP_HOST_FIRST_DIRECTORY_PATH`: "/directory/that/you/want/to/backup/on/the/host"
- `BORG_BACKUP_HOST_SECOND_DIRECTORY_PATH`: "/optionally/second/path"
- `DOCKER_COMPOSE_DIRECTORY_ONE`: "/home/chris/testDockerDir/compose/docker-compose.yml"
- `DOCKER_COMPOSE_DIRECTORY_SECOND`: "/home/chris/testDockerDir/compose/docker-compose.yml"
- `LOG_DIRECTORY`: "."
- `GOTIFY_SERVERNAME`: "TEST-SERVER"
- `GOTIFY_ENDPOINT_WITH_API_KEY`: "https://GOTIFY.domain-name.com/message?token=TOKEN_KEY"


---

TODO: Update docs for the repo listings.
Create new repo dependant on python.