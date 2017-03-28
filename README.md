Rollator is a script to do systemd-docker updates from a external CI tool.

## Installation

### Server side

```bash

# Install dependency:
apt-get install inotify-tools

git clone https://github.com/fabianhauser/rollator.git /opt/rollator
mkdir /var/lib/rollator

groupadd --system rollator
cat <<'__EOF__' >> /etc/ssh/sshd_config
Match Group rollator
        ForceCommand touch restart
__EOF__

systemctl restart sshd
```

#### Add Service

```bash
SERVICE=nginx 
CONTAINER=nginx

useradd --system \
    --home-dir /var/lib/rollator/${SERVICE} --create-home --skel /opt/rollator/skel \
    --gid rollator --no-user-group \
    rollator-${SERVICE}

su -c 'ssh-keygen -q -t ed25519 ' rollator-${SERVICE}
# Accept defaults
# Add following private key to your service under env variable SSH_KEY
cat /var/lib/rollator/${SERVICE}/.ssh/id_ed25519 | base64 --wrap=0

# Add the rollator service to the nginx search path
systemctl link /var/lib/rollator/systemd/nginx-rollator.service
# You would probably copy and adjust this file to your needs.
systemctl start nginx-rollator.service


```

### Client side
```bash
mkdir ~/.ssh/
base64 -d <<__EOF__ > ~/.ssh/id_ed25519
${SSH_KEY}
__EOF__
chmod -R 700 ~/.ssh

# Call the remote host to execute reload:
ssh rollator-nginx@YOURHOST
```
