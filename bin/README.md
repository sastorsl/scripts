# Shell scripts

Misc shell-scripts. Mostly written adhoc, but some useful.


## bin/backup-file.sh
Make a backup into a `back/` directory.
Requires that you are in - `cd <dir>` - the directory where the file is, and that you have privileges to create, or write to, a `back` sub-directory.

```bash
# CORRECT
cd /directory
backup-file.sh filename.txt

# INCORRECT
backup-file.sh /directory/filename.txt
```

# download-kubernetes-tools.sh
Download the _latest_ versions of kubernetes tools.
NB! You might need older versions if you are working with older clusters.
In that case you have to download those versions manually.

```bash
# Download and run the install script directly with curl | bash
curl -sS https://raw.githubusercontent.com/sastorsl/scripts/main/bin/download-kubernetes-tools.sh | bash

# Override the default directory and run with `sudo` (`-s` option to the script) by using the `bash -s` option.
curl -sS https://raw.githubusercontent.com/sastorsl/scripts/main/bin/download-kubernetes-tools.sh | bash -s -- -d /usr/local/bin -s
```

## list-spf.sh
Get the SPF record from a hosts TXT-record in DNS, and iterate until all nested SPF records are listed.

```bash
list-spf.sh vg.no
```

