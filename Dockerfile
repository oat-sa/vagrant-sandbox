# Docker image to use with Vagrant
# Adapted from https://github.com/BashtonLtd/docker-vagrant-images/blob/master/ubuntu1404/Dockerfile

# Define the base environment
FROM ubuntu:20.04
ENV container docker

# Install system dependencies
RUN apt-get update -y && apt-get dist-upgrade -y \
    && apt-get install -y --no-install-recommends ssh sudo systemd openssh-client puppet

# Add vagrant user and key for SSH
RUN useradd --create-home -s /bin/bash vagrant \
    && echo -n 'vagrant:vagrant' | chpasswd \
    && echo 'vagrant ALL=(ALL) NOPASSWD: ALL' > /etc/sudoers.d/vagrant \
    && chmod 440 /etc/sudoers.d/vagrant \
    && mkdir -p /home/vagrant/.ssh \
    && chmod 700 /home/vagrant/.ssh \
    && echo "ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEA6NF8iallvQVp22WDkTkyrtvp9eWW6A8YVr+kz4TjGYe7gHzIw+niNltGEFHzD8+v1I2YJ6oXevct1YeS0o9HZyN1Q9qgCgzUFtdOKLv6IedplqoPkcmF0aYet2PkEDo3MlTBckFXPITAMzF8dJSIFo9D8HfdOV0IAdx4O7PtixWKn5y2hMNG0zQPyUecp4pzC6kivAIhyfHilFR61RGL+GPXQ2MWZWFYbAGjyiYJnAmCP3NOTd0jMZEnDkbUvxhMmBYSdETk1rRgm+R4LOzFUGaHqHDLKLX+FIPKcF96hrucXzcWyLbIbEgE98OHlnVYCzRdK8jlqm8tehUc9c9WhQ==" > /home/vagrant/.ssh/authorized_keys \
    && chmod 600 /home/vagrant/.ssh/authorized_keys \
    && chown -R vagrant:vagrant /home/vagrant/.ssh \
    && sed -i -e 's/Defaults.*requiretty/#&/' /etc/sudoers \
    && sed -i -e 's/\(UsePAM \)yes/\1 no/' /etc/ssh/sshd_config \
    && mkdir /var/run/sshd \
    && /usr/sbin/sshd

# Allow connection to SSH
EXPOSE 22

# Allow connection to the web server
EXPOSE 80
EXPOSE 443

# Start Systemd (systemctl)
CMD ["/lib/systemd/systemd"]
