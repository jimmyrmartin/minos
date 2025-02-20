#! /bin/bash

# Create a data staging area for all downloaded data
mkdir /tmp/downloads
mkdir /root/new-kernel

# First we will install a newer kernel. This will use 6.11.11, it's the latest kernel that passes the build tests.

cd /root/new-kernel

wget {https://kernel.ubuntu.com/mainline/v6.11.11/amd64/linux-headers-6.11.11-061111-generic_6.11.11-061111.202412051415_amd64.deb,https://kernel.ubuntu.com/mainline/v6.11.11/amd64/linux-headers-6.11.11-061111_6.11.11-061111.202412051415_all.deb,https://kernel.ubuntu.com/mainline/v6.11.11/amd64/linux-image-unsigned-6.11.11-061111-generic_6.11.11-061111.202412051415_amd64.deb,https://kernel.ubuntu.com/mainline/v6.11.11/amd64/linux-modules-6.11.11-061111-generic_6.11.11-061111.202412051415_amd64.deb}

apt install ./*.deb -y

# Get rid of snap
systemctl disable snapd
systemctl mask snapd
apt purge snapd -y
apt-mark hold snapd
rm -rf ~/snap/

# Prepare software install
apt update && apt install -y openssh-server \
yq \
jq \
cockpit \
sysstat \
tcpdump \
ethtool \
prometheus-node-exporter \
vim \
clustershell \
ansible \
iperf

# Create minio-user and group also create minio certs dir
groupadd -r minio-user
useradd -m -r -g minio-user minio-user
mkdir -p /home/minio-user/.minio/certs/CAs
chown -R minio-user:minio-user /home/minio-user/.minio/certs/

cd /tmp/downloads

# Download and install latest aistor
wget https://dl.min.io/aistor/minio/release/linux-amd64/minio.deb -O minio.deb
dpkg -i minio.deb

# Chown /etc/default/minio as minio-user

chown minio-user: /etc/default/minio

# Grab all the MinIO utils
wget {https://github.com/minio/dperf/releases/download/v0.6.3/dperf_0.6.3_linux_amd64.deb,https://github.com/minio/hperf/releases/download/v5.0.4/hperf_5.0.4_linux_amd64.deb,https://github.com/minio/warp/releases/download/v1.1.0/warp_Linux_x86_64.deb,https://dl.min.io/client/mc/release/linux-amd64/mc.deb}

# Install MinIO utils
apt install ./*.deb -y

# Create symlink for mc instead of mcli

ln -s /usr/local/bin/mcli /usr/local/bin/mc

# Set owner of /usr/local/bin to be minio-user
chown -R minio-user: /usr/local/bin
