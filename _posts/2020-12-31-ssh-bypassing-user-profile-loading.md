---
title: SSH Bypassing User Profile Loading
layout: default
description: Prevent a user profile being loaded when connecting over SSH
---

## Written: 2020-12-31

I recently ran into an issue where I was completing a Git merge, following a fetch of the latest version of a remote repo. On this occasion I ran into a merge conflict, however I overlooked this and thought everything had completed as expected. My next step in the testing workflow was to build out a `.deb` package and upload it to one of our dev servers and install it.

This wouldn't have been an issue, however the `.bashrc` on this occasion happens to call a a shell script when a user logs in over SSH. The merge conflit I mentioned was accidentally introduced in this shell script that is automatically called and I was starting to hit errors when trying to log in:

```
-bash: /usr/local/lib/path/to/the/script.sh: line 20: syntax error near unexpected token `&lt;&lt;&lt;'
-bash: /usr/local/lib/<code>path/to/the/script</code>.sh: line 20: `&lt;&lt;&lt;&lt;&lt;&lt;&lt; HEAD'
Connection to dev.server closed.
```

I essentially locked myself as well as all the other users out of accessing this server, since the Git merge conflict headers were present in the script that was automatically called by the profile. After some research, I located a handy method to starting a SSH connection and calling Bash without a user profile:

```
ssh user@dev.server "bash --noprofile"
```

The `--noprofile` flag specifically prevents profiles from loading as explained in the [Bash man pages](https://linux.die.net/man/1/bash). This includes both the default profile found at `/etc/profile` and local user profiles such as `/home/user/.bashrc`.

This is great, I was able to log in without the critical error and getting thrown out of the SSH session, however at the same time, what I found was that this also meant a `TTY` terminal control session was not started and I was unable to run commands such as `sudo` in order to edit or remove the file causing the issues. I kept running into the following error:

```
sudo: no tty present and no askpass program specified
```

After some searching I found a great article on [shell-tips.com](https://www.shell-tips.com/linux/sudo-no-tty-present-and-no-askpass-program-specified/) that shed some further light on to what was happening with regard to the lack of a `TTY` session and the proposed fix being adding the `-t` flag to the `SSH` call. In a nutshell the flag provides a pseudo-sudo shell when the connection is made, allowing me to run `sudo` commands without loading the profiles that were calling the corrupt file. The command in full would be:

```
ssh -t user@dev.server "bash --noprofile"
```

I was able to successfully amend the file on the server and restore access while resolving the merge conflict locally and successfully merging the branches. The above is a great way to get around issues where a script being called from a user profile fails and your SSH session fails to load.
