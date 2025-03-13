---
title: Keep servers updated with Ansible
layout: default
description: Update Ubuntu servers via Ansible
---

I have started to dabble with Ansible in order to run some regular tasks such as updating my Raspberry Pi run locally as well as one of my AWS EC2 instances. This just helps make sure my `apt` packages as well as overall system updates are processed.

My setup for the server updates is fairly straight forward. I have my SSH keys and hosts defined within my `~/.ssh/config` file, which I am then able to use with my Ansible host file. In this case I have a couple of files to run this Ansible setup.

First is my `hosts` file, which contains some variables that are used with the Ansible script, identifying the user for each server. I then create groups, one for my local server(s) and one for my aws server(s) to execute on.


{% highlight shell %}
[local:vars]
ansible_user = 'rpiuser'

[aws:vars]
ansible_user = 'ubuntulogin'

## server names to connect to ##
[local]
rpi-home

[aws]
aws-ec2-main
{% endhighlight %}

My YAML file for Ansible is fairly straight forward:

{% highlight yaml %}
---
- hosts: all
  become: true
  become_user: root
  tasks:
    - name: Update apt repo and cache on all Ubuntu servers
      apt: update_cache=yes force_apt_get=yes cache_valid_time=3600

    - name: Upgrade all packages on servers
      apt: upgrade=dist force_apt_get=yes

    - name: Check if a reboot is needed on servers
      register: reboot_required_file
      stat: path=/var/run/reboot-required get_md5=no

    - name: Reboot the box if kernel updated
      reboot:
        msg: "Reboot initiated by Ansible for kernel updates"
        connect_timeout: 5
        reboot_timeout: 300
        pre_reboot_delay: 0
        post_reboot_delay: 30
        test_command: uptime
      when: reboot_required_file.stat.exists
{% endhighlight %}

In this case:
- I ensure that `apt` is updated
- Update `apt` packages across the server
- Check if the system requires a restart based on the `/var/run/reboot-required` file
- Reboot the server if the file is present

This works great for both my Raspberry Pi as well as the EC2. In the case of the EC2 I had to make a modification. I run an application on there through Docker, which did not come back up after the re-start.

I checked that the NGINX server was up and running as well as Docker before I realized that the container failed to restart. This was a fairly easy solution using [Docker Restart Policies](https://docs.docker.com/engine/containers/start-containers-automatically/). By adding the following line into my Docker compose file I was able to ensure that when the system restarted, so did the Docker container:

{% highlight yaml %}
    restart: always
{% endhighlight %}

The script now runs successfully and restarts the servers as needed:

{% highlight shell %}
ansible-playbook -i hosts update.yml -K
BECOME password:

PLAY [all] *********************************************************************

TASK [Gathering Facts] *********************************************************
ok: [rpi-home]
ok: [aws-ec2-main]

TASK [Update apt repo and cache on all Ubuntu servers] *************************
changed: [aws-ec2-main]
ok: [rpi-home]

TASK [Upgrade all packages on servers] *****************************************
changed: [aws-ec2-main]
changed: [rpi-home]

TASK [Check if a reboot is needed on servers] **********************************
ok: [rpi-home]
ok: [aws-ec2-main]

TASK [Reboot the box if kernel updated] ****************************************
skipping: [rpi-home]
changed: [aws-ec2-main]

PLAY RECAP *********************************************************************
aws-ec2-main               : ok=5    changed=3    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
rpi-home                   : ok=4    changed=1    unreachable=0    failed=0    skipped=1    rescued=0    ignored=0
{% endhighlight %}
