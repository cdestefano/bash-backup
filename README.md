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