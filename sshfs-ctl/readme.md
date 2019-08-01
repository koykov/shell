# SSHFS control
Provides easy mount/unmount features for sshfs.

## Basic Usage
`sshfs-up <host_name>`
takes connection info from the `.ssh/config` file and mount the remote directory to local.  

`sshfs-down <host_name>`
unmounts the mounted remote directory. 

## Advanced Usage
`sshfs-ctl` supports the following command line arguments:
* `--action` (alias `-a`) kind of operation, possible variants `up` and `down` (*)
* `--user` (`-u`) remote username
* `--pass` (`-p`) password
* `--host` (`-h`) remote hostname of IP address
* `--dir` (`-d`) remote directory to mount (by default uses `/home/<remote_user>`)
* `--mount-point` (`-m`) local directory to mount (will create automatically, by default uses `/home/<local_user>/rem/<host>`)
* `--verbose` (`-v`) display verbose information


\* action `up` will use by default

## Options
All `sshfs` options you need to use, write to the local file `options`.
By default uses two of them:
* workaround=rename
* follow_symlinks

You may see the whole list of the options using `sshfs --help`.